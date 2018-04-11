import psycopg2
from psycopg2 import sql

feat_view_map = {
    "RoundPipe": "utn9_ntw_feat_distrib_elem_pipe_round"
}
feat_table_map = {
    "RoundPipe": "utn9_distrib_element"
}

def getPropertyById(cur, id, property, table="cityobject"):
    
    """
    Returns the value of the given property (column name) for the feature with the given id. If no
    table is specified, it defaults to using the "cityobject" table.
    """

    query = sql.SQL("""
    
        SELECT {property} FROM citydb.{table} WHERE id = %(id)s
    
    """).format(
        property = sql.Identifier(property),
        table = sql.Identifier(table),
    )
    
    cur.execute(query, {"id": id})
    
    return cur.fetchone()[0]


def setPropertyById(cur, id, property, value):
    
    if isinstance(id, list):
        id = tuple(id)
    else:
        id = (id)
    
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
        "id": id,
        "value": value
    })
    
    return None


def getPropertyByGMLId(cur, gmlid, property, table="cityobject"):

    """
    Returns the value of the given property (column name) for the feature with the given gml id. If no
    table is specified, it defaults to using the "cityobject" table.
    """

    query = sql.SQL("""
    
        SELECT {property} FROM citydb.{table} WHERE gmlid = %(gmlid)s
    
    """).format(
        property = sql.Identifier(property),
        table = sql.Identifier(table),
    )
    
    cur.execute(query, {"gmlid": gmlid})
    
    return cur.fetchone()[0]


def getAllIdsByCriteria(cur, objectclass, status="inUse"):
    
    """
    TODO: docstring for getAllIdsByObjectClass
    """
    
    view = feat_view_map[objectclass]
    
    query = sql.SQL("""
    
        SELECT
            id
        FROM
            citydb_view.{view}
        WHERE
            status = %(status)s
    
    """).format(
        view = sql.Identifier(view)
    )
    
    cur.execute(query, {
        "objectclass": objectclass,
        "status": status
    })
    
    return [i[0] for i in cur.fetchall()]

if __name__ == "__main__":
    
    print("hello world")
    
    conn = psycopg2.connect("host=eif-pg-96-01 dbname=isaac_thesis user=isaac_thesis_serviceaccount password=z23jIfZXKaoUrG8F")
    # conn = psycopg2.connect("host=localhost dbname=unade user=postgres password=postgres")
    
    cur = conn.cursor()
    
    #print(getPropertyByGMLId(cur, getPropertyById(cur, 14, 'gmlid'), 'name'))
    print(getAllIdsByCriteria(cur, "RoundPipe"))
    
    setPropertyById(cur, [435,436,437], "status", "outOfService")
    print(getAllIdsByCriteria(cur, "RoundPipe"))
    
