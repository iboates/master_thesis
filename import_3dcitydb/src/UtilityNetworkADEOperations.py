import warnings
import sys
import psycopg2
from psycopg2 import sql

feat_view_map = {
    "RoundPipe": "utn9_ntw_feat_distrib_elem_pipe_round"
}
feat_table_map = {
    "RoundPipe": "utn9_distrib_element"
}

def forceTuple(value):
    
    """
    TODO: docstring for forceTuple()
    """
    
    if isinstance(value, tuple):
        return value
    elif isinstance(value, list):
        return tuple(value)
    else:
        return (value, )


def releaseResult(cur):
    
    result = [i[0] for i in cur.fetchall()]
    if len(result) == 1:
        return result[0]
    else:
        return result


def getPropertyById(cur, id, property, table="cityobject"):
    
    """
    TODO: docstring for getPropertyById()
    """

    query = sql.SQL("""
    
        SELECT {property} FROM citydb.{table} WHERE id IN %(id)s
    
    """).format(
        property = sql.Identifier(property),
        table = sql.Identifier(table),
    )
    
    cur.execute(query, {"id": forceTuple(id)})
    
    return releaseResult(cur)
    

def setPropertyById(cur, id, property, value):
    
    """
    TODO: docstring for setPropertyById()
    """
    
    query = sql.SQL("""
    
        UPDATE
            citydb.utn9_network_feature
        SET
            {property} = %(value)s
        WHERE
            id IN %(id)s
    
    """).format(
        property = sql.Identifier(property)
    )
    
    cur.execute(query, {
        "id": forceTuple(id),
        "value": value
    })
    
    return None


def getAllIdsByCriteria(cur, objectclass, property, value):
    
    """
    TODO: docstring for getAllIdsByCriteria()
    """
    
    view = feat_view_map[objectclass]
    
    query = sql.SQL("""
    
        SELECT
            id
        FROM
            citydb_view.{view}
        WHERE
            {property} = %(value)s
    
    """).format(
        view = sql.Identifier(view),
        property = sql.Identifier(property)
    )
    
    cur.execute(query, {
        "objectclass": objectclass,
        "value": value
    })
    
    return [i[0] for i in cur.fetchall()]


def getAllConnectedTerminalElementIds(cur, network_id, source=None):

    """
    TODO: getAllConnectedTerminalElementIds docstring
    """

    query = sql.SQL("""
    
        SELECT DISTINCT
            te.id
        FROM
            pgr_dijkstra(
                /* Traversing the links. Here, costs are assumed to be the length of links, =1 otherwise */
                'SELECT
                    id,
                    start_node_id AS source,
                    end_node_id AS target,
                    cost,
                    reverse_cost
                FROM (
                    /* Link has a line geometry, use its length as cost. */
                    SELECT
                        oc.classname,
                        l.id,
                        l.gmlid,
                        l.start_node_id,
                        l.end_node_id,
                        ST_Length(l.line_geom) AS cost,
                        ST_Length(l.line_geom) AS reverse_cost,
                        l.line_geom AS geom
                    FROM
                        citydb.objectclass AS oc,
                        citydb.utn9_link AS l,
                        citydb_view.utn9_feature_graph AS fg,
                        citydb_view.utn9_network AS net,
                        citydb_view.utn9_network_graph AS ng
                    WHERE
                        net.id = ' || %(network_id)s || '
                        AND
                        ng.network_id = net.id
                        AND
                        (
                            (l.feat_graph_id = fg.id
                            AND
                            fg.ntw_graph_id = ng.id)
                            OR
                            (l.ntw_graph_id = ng.id)
                        )
                        AND
                        l.line_geom IS NOT NULL
                        AND
                        oc.id = l.objectclass_id
        
                    UNION ALL
        
                    /* Link has no line geometry, use 1 as cost. */
                    SELECT
                        oc.classname,
                        l.id,
                        l.gmlid,
                        l.start_node_id,
                        l.end_node_id,
                        1 AS cost,
                        1 AS reverse_cost,
                        l.line_geom AS geom
                    FROM
                        citydb.objectclass AS oc,
                        citydb.utn9_link AS l,
                        citydb_view.utn9_feature_graph AS fg,
                        citydb_view.utn9_network AS net,
                        citydb_view.utn9_network_graph AS ng
                    WHERE
                        net.id = ' || %(network_id)s || '
                        AND
                        ng.network_id = net.id
                        AND
                        (
                            (l.feat_graph_id = fg.id
                            AND
                            fg.ntw_graph_id = ng.id)
                            OR
                            (l.ntw_graph_id = ng.id)
                        )
                        AND
                        l.line_geom IS NULL
                        AND
                        oc.id = l.objectclass_id
                ) AS graph
        
                /* Exclude links that come from a feature that is status=''outOfService'' */
                WHERE start_node_id NOT IN (SELECT
                                n.id AS n_id
                            FROM
                                citydb_view.utn9_node AS n,
                                citydb_view.utn9_feature_graph AS fg,
                                citydb.utn9_network_feature AS nf
                            WHERE
                                nf.status = ''outOfService''
                                AND
                                n.feat_graph_id = fg.id
                                AND
                                fg.ntw_feature_id = nf.id)
                AND end_node_id NOT IN (SELECT
                                n.id AS n_id
                            FROM
                                citydb_view.utn9_node AS n,
                                citydb_view.utn9_feature_graph AS fg,
                                citydb.utn9_network_feature AS nf
                            WHERE
                                nf.status = ''outOfService''
                                AND
                                n.feat_graph_id = fg.id
                                AND
                                fg.ntw_feature_id = nf.id)',
        
                /* Use the node from the only entry in the "Storage Device" view as a source node. */
                (SELECT
                    n.id AS id
                FROM
                    citydb_view.utn9_ntw_feat_device_storage AS sd,
                    citydb_view.utn9_node AS n,
                    citydb_view.utn9_feature_graph AS fg,
                    citydb_view.utn9_network AS net,
                    citydb_view.utn9_network_graph AS ng
                WHERE
                    net.name = 'Water Network'
                    AND
                    ng.network_id = net.id
                    AND
                    n.feat_graph_id = fg.id
                    AND
                    fg.ntw_feature_id = sd.id
                    AND
                    fg.ntw_graph_id = ng.id),
        
                /* Use all the nodes from the entries in the "Terminal Element" view as target nodes. */
                (SELECT
                    array_agg(n.id) AS id
                FROM
                    citydb_view.utn9_ntw_feat_term_elem AS te,
                    citydb_view.utn9_node AS n,
                    citydb_view.utn9_feature_graph AS fg,
                    citydb_view.utn9_network AS net,
                    citydb_view.utn9_network_graph AS ng
                WHERE
                    net.id = %(network_id)s
                    AND
                    ng.network_id = net.id
                    AND
                    n.feat_graph_id = fg.id
                    AND
                    fg.ntw_feature_id = te.id
                    AND
                    fg.ntw_graph_id = ng.id)
            )
        AS sr,
        citydb.utn9_link AS l,
        citydb_view.utn9_node AS n,
        citydb_view.utn9_feature_graph AS fg,
        citydb_view.utn9_network_graph AS ng,
        citydb_view.utn9_network AS net,
        citydb_view.utn9_ntw_feat_term_elem AS te
        
        /* Join the link information to the routing result to get its geometry & id (ignore those without geometry). */
        WHERE
            l.line_geom IS NOT NULL
            AND
            l.id = sr.edge
            AND
            n.feat_graph_id = fg.id
            AND
            fg.ntw_graph_id = ng.id
            AND
            ng.network_id = net.id
            AND
            net.id = %(network_id)s
            AND
            fg.ntw_feature_id = te.id
    
    """)
    
    cur.execute(query, {
        "network_id": network_id
    })
    
    return releaseResult(cur)


if __name__ == "__main__":
    
    conn = psycopg2.connect("host=eif-pg-96-01 dbname=isaac_thesis user=isaac_thesis_serviceaccount password=z23jIfZXKaoUrG8F")
    # conn = psycopg2.connect("host=localhost dbname=unade user=postgres password=postgres")
    
    cur = conn.cursor()
    
#     print(getPropertyById(cur, 14, 'name'))
#     print(getPropertyById(cur, [14, 15, 16], 'name'))
#     print(getPropertyById(cur, (14, 15, 16), 'name'))
#     print(getAllIdsByCriteria(cur, "RoundPipe", "status", "inUse"))
    setPropertyById(cur, 495, "status", "outOfService")
    conn.commit()
    print(len(getAllConnectedTerminalElementIds(cur, 177)))
    
    
    # conn.commit()
    
