### NOTES
### The features need to loop BACK through their feature graphs in the network graph and update the FG's "ntw_feature_id" property
###
###

ALLOWED_RELATIONS = ["{http://www.citygml.org/ade/utility/0.9.2}component",
                     "{http://www.citygml.org/ade/utility/0.9.2}topoGraph",
                     "{http://www.citygml.org/ade/utility/0.9.2}featureGraphMember",
                     "{http://www.citygml.org/ade/utility/0.9.2}nodeMember",
                     "{http://www.citygml.org/ade/utility/0.9.2}linkMember", ]

import xml.etree.ElementTree as ET
import psycopg2
from psycopg2 import sql

ns = {'utility': "http://www.citygml.org/ade/utility/0.9.2",
          'gml': "http://www.opengis.net/gml"}

properties = {
    "Network": ["class", "function", "usage", ],
    "NetworkGraph": [],
    "FeatureGraph": [],
    "Node": ["type", "connectionSignature", "linkControl"],
    "InteriorFeatureLink": ["direction", "linkControl", ],
    "RoundPipe": ["function", "usage", "connectedCityObject", "yearOfConstruction", "status", "locationQuality",
                  "elevationQuality", "class", "functionOfLine", "isGravity", "exteriorWidth", "exteriorHeight",
                  "exteriorDiameter", "interiorDiameter", ],
    "TerminalElement": ["function", "usage", "connectedCityObject", "yearOfConstruction", "status", "locationQuality",
                        "elevationQuality", "class", ],
}

relations = {
    "Network": ["component", "topoGraph", ],
    "NetworkGraph": ["featureGraphMember", "linkMember", ],
    "FeatureGraph": ["nodeMember", "linkMember", "networkLinkMember", ],
    "Node": ["realiziation", ],
    "InteriorFeatureLink": ["start", "end", "realization", ],
    "RoundPipe": ["lod1Geometry", "consistsOf", "hasMaterial", "topoGraph", ],
    "TerminalElement": ["lod1Geometry", ]
}

queries = {
    "Network": sql.SQL("""
        SELECT citydb_view.utn9_insert_network(
            id := %(id)s,
            gmlid := %(gmlid)s,
            gmlid_codespace := %(gmlid_codespace)s,
            name := %(name)s,
            name_codespace := %(name_codespace)s,
            description := %(description)s,
            envelope := %(envelope)s,
            creation_date := %(creation_date)s,
            termination_date := %(termination_date)s,
            relative_to_terrain := %(relative_to_terrain)s,
            relative_to_water := %(relative_to_water)s,
            last_modification_date := %(last_modification_date)s,
            updating_person := %(updating_person)s,
            reason_for_update := %(reason_for_update)s,
            lineage := %(lineage)s,
            network_parent_id := %(network_parent_id)s,
            network_root_id := %(network_root_id)s,
            class := %(class)s,
            function := %(function)s,
            usage := %(usage)s,
            commodity_id := %(commodity_id)s,
            schema_name := %(schema_name)s
        );
    """),
    "NetworkGraph": sql.SQL("""
        SELECT citydb_view.utn9_insert_network_graph(
            id := %(id)s,
            gmlid := %(gmlid)s,
            gmlid_codespace := %(gmlid_codespace)s,
            name := %(name)s,
            name_codespace := %(name_codespace)s,
            description := %(description)s,
            network_id := %(network_id)s,
            schema_name := %(schema_name)s
        );
    """),
    "FeatureGraph": sql.SQL("""
        SELECT citydb_view.utn9_insert_feature_graph(
            id := %(id)s,
            gmlid := %(gmlid)s,
            gmlid_codespace := %(gmlid_codespace)s,
            name := %(name)s,
            name_codespace := %(name_codespace)s,
            description := %(description)s,
            ntw_feature_id := %(ntw_feature_id)s,
            ntw_graph_id := %(ntw_graph_id)s,
            schema_name := %(schema_name)s
        );
    """),
    "Node": sql.SQL("""
        SELECT citydb_view.utn9_insert_node(
            id := %(id)s,
            gmlid := %(gmlid)s,
            gmlid_codespace := %(gmlid_codespace)s,
            name := %(name)s,
            name_codespace := %(name_codespace)s,
            description := %(description)s,
            type := %(type)s,
            connection_signature := %(connectionSignature)s,
            link_control := %(linkControl)s,
            feat_graph_id := %(feat_graph_id)s,
            point_geom := ST_GeomFromText(%(geom)s, %(srid)s)
        );
    """),
    "InteriorFeatureLink": sql.SQL("""
        SELECT citydb_view.utn9_insert_link_interior_feature(
            id := %(id)s,
            gmlid := %(gmlid)s,
            gmlid_codespace := %(gmlid_codespace)s,
            name := %(name)s,
            name_codespace := %(name_codespace)s,
            description := %(description)s,
            link_control := %(linkControl)s,
            direction := %(direction)s,
            start_node_id := %(start_node_id)s,
            end_node_id := %(end_node_id)s,
            feat_graph_id := %(feat_graph_id)s,
            line_geom := ST_GeomFromText(%(geom)s, %(srid)s)
        );
    """),
    "RoundPipe": sql.SQL("""
        WITH rp AS (
            SELECT citydb_view.utn9_insert_ntw_feat_distrib_elem_pipe_round(
                id := %(id)s,
                gmlid := %(gmlid)s,
                gmlid_codespace := %(gmlid_codespace)s,
                name := %(name)s,
                name_codespace := %(name_codespace)s,
                description := %(description)s,
                envelope := ST_Expand(ST_GeomFromText(%(geom)s, %(srid)s), 0),
                creation_date := %(creation_date)s,
                termination_date := %(termination_date)s,
                relative_to_terrain := %(relative_to_terrain)s,
                relative_to_water := %(relative_to_water)s,
                last_modification_date := %(last_modification_date)s,
                updating_person := %(updating_person)s,
                reason_for_update := %(reason_for_update)s,
                lineage := %(lineage)s,
                ntw_feature_parent_id := %(ntw_feature_parent_id)s,
                ntw_feature_root_id := %(ntw_feature_root_id)s,
                class := %(class)s,
                function := %(function)s,
                usage := %(usage)s,
                year_of_construction := %(yearOfConstruction)s,
                status := %(status)s,
                location_quality := %(locationQuality)s,
                elevation_quality := %(elevationQuality)s,
                cityobject_id := %(cityobject_id)s,
                prot_element_id := %(prot_element_id)s,
                geom := ST_GeomFromText(%(geom)s, %(srid)s),
                function_of_line := %(functionOfLine)s,
                is_gravity := %(isGravity)s,
                ext_width := %(ext_width)s,
                ext_width_unit := %(ext_width_unit)s,
                ext_height := %(ext_height)s,
                ext_height_unit := %(ext_height_unit)s,
                ext_diameter := %(exteriorDiameter)s,
                ext_diameter_unit := %(ext_diameter_unit)s,
                int_diameter := %(int_diameter)s,
                int_diameter_unit := %(int_diameter_unit)s,
                schema_name := 'citydb'
            ) AS fid
        ),
        
        x AS (
            SELECT citydb_pkg.utn9_insert_network_to_network_feature(
                network_id := %(network_id)s,
                network_feature_id := rp.fid,
                schema_name := 'citydb'
            ) FROM rp
        )
        
        UPDATE
            citydb.utn9_feature_graph
        SET
            ntw_feature_id = (SELECT rp.fid FROM rp)
        WHERE
            id = %(featuregraph_id)s
        RETURNING
            (SELECT rp.fid FROM rp);
    """),
    "TerminalElement": sql.SQL("""
        WITH te AS (
            SELECT citydb_view.utn9_insert_ntw_feat_term_elem(
                id := %(id)s,
                gmlid := %(gmlid)s,
                gmlid_codespace := %(gmlid_codespace)s,
                name := %(name)s,
                name_codespace := %(name_codespace)s,
                description := %(description)s,
                envelope := ST_Expand(ST_GeomFromText(%(geom)s, %(srid)s), 0),
                creation_date := %(creation_date)s,
                termination_date := %(termination_date)s,
                relative_to_terrain := %(relative_to_terrain)s,
                relative_to_water := %(relative_to_water)s,
                last_modification_date := %(last_modification_date)s,
                updating_person := %(updating_person)s,
                reason_for_update := %(reason_for_update)s,
                lineage := %(lineage)s,
                ntw_feature_parent_id := %(ntw_feature_parent_id)s,
                ntw_feature_root_id := %(ntw_feature_root_id)s,
                class := %(class)s,
                function := %(function)s,
                usage := %(usage)s,
                year_of_construction := %(yearOfConstruction)s,
                status := %(status)s,
                location_quality := %(locationQuality)s,
                elevation_quality := %(elevationQuality)s,
                cityobject_id := %(cityobject_id)s,
                prot_element_id := %(prot_element_id)s,
                geom := ST_GeomFromText(%(geom)s, %(srid)s),
                schema_name := 'citydb'
            ) AS fid
        ),
        
        x AS (
            SELECT citydb_pkg.utn9_insert_network_to_network_feature(
                network_id := %(network_id)s,
                network_feature_id := te.fid,
                schema_name := 'citydb'
            ) FROM te
        )
        
        UPDATE
            citydb.utn9_feature_graph
        SET
            ntw_feature_id = (SELECT te.fid FROM te)
        WHERE
            id = %(featuregraph_id)s
        RETURNING
            (SELECT te.fid FROM te);
    """)
}

exec_dicts = {
    "Network": {
        "id": None,
        "gmlid": None,
        "gmlid_codespace": None,
        "name": None,
        "name_codespace": None,
        "description": None,
        "envelope": None,
        "creation_date": None,
        "termination_date": None,
        "relative_to_terrain": None,
        "relative_to_water": None,
        "last_modification_date": None,
        "updating_person": None,
        "reason_for_update": None,
        "lineage": None,
        "network_parent_id": None,
        "network_root_id": None,
        "class": None,
        "function": None,
        "usage": None,
        "commodity_id": None,
        "schema_name": "citydb",
    },
    "NetworkGraph": {
        "id": None,
        "gmlid": None,
        "gmlid_codespace": None,
        "name": None,
        "name_codespace": None,
        "description": None,
        "network_id": None,
        "schema_name": 'citydb'
    },
    "FeatureGraph": {
        "id": None,
        "gmlid": None,
        "gmlid_codespace": None,
        "name": None,
        "name_codespace": None,
        "description": None,
        "ntw_feature_id": None,
        "ntw_graph_id": None,
        "schema_name": "citydb"
    },
    "Node": {
        "id": None,
        "gmlid": None,
        "gmlid_codespace": None,
        "name": None,
        "name_codespace": None,
        "description": None,
        "type": None,
        "connectionSignature": None,
        "linkControl": None,
        "feat_graph_id": None,
        "srid": None,
        "geom": None
    },
    "InteriorFeatureLink": {},
    "RoundPipe": {
        "id": None,
        "gmlid": None,
        "gmlid_codespace": None,
        "name": None,
        "name_codespace": None,
        "description": None,
        "envelope": None,
        "creation_date": None,
        "termination_date": None,
        "relative_to_terrain": None,
        "relative_to_water": None,
        "last_modification_date": None,
        "updating_person": None,
        "reason_for_update": None,
        "lineage": None,
        "ntw_feature_parent_id": None,
        "ntw_feature_root_id": None,
        "class": None,
        "function": None,
        "usage": None,
        "yearOfConstruction": None,
        "status": None,
        "locationQuality": None,
        "elevationQuality": None,
        "cityobject_id": None,
        "prot_element_id": None,
        "geometry": None,
        "functionOfLine": None,
        "isGravity": None,
        "ext_width": None,
        "ext_width_unit": None,
        "ext_height": None,
        "ext_height_unit": None,
        "exteriorDiameter": None,
        "ext_diameter_unit": None,
        "int_diameter": None,
        "int_diameter_unit": None,
        "schema_name": "citydb",
        "srid": None,
        "network_id": None,
    },
    "TerminalElement": {
        "id": None,
        "gmlid": None,
        "gmlid_codespace": None,
        "name": None,
        "name_codespace": None,
        "description": None,
        "envelope": None,
        "creation_date": None,
        "termination_date": None,
        "relative_to_terrain": None,
        "relative_to_water": None,
        "last_modification_date": None,
        "updating_person": None,
        "reason_for_update": None,
        "lineage": None,
        "ntw_feature_parent_id": None,
        "ntw_feature_root_id": None,
        "class": None,
        "function": None,
        "usage": None,
        "yearOfConstruction": None,
        "status": None,
        "locationQuality": None,
        "elevationQuality": None,
        "cityobject_id": None,
        "prot_element_id": None,
        "geometry": None,
        "schema_name": "citydb",
        "srid": None,
        "network_id": None,
    },
}

last_id_inserted = {
    "Network": 0,
    "NetworkGraph": 0,
    "FeatureGraph": 0,
    "Node": 0,
    "InteriorFeatureLink": 0,
    "RoundPipe": 0,
    "TerminalElement": 0,
}

superordinate_ids = {
    "Network": None,
    "NetworkGraph": "network_id",
    "FeatureGraph": "ntw_graph_id",
    "Node": "feat_graph_id",
    "InteriorFeatureLink": "feat_graph_id",
    "RoundPipe": "network_id",
    "TerminalElement": "network_id",
}


def import_feature(xml_element, last_feature_type_inserted, superordinate_id, cur):

    # get the feature type from the tag and its associated SQL execution dictionary
    feature_type = xml_element.tag[xml_element.tag.find("}")+1:]
    exec_dict = exec_dicts[feature_type].copy()

    # set the GML id
    exec_dict["gmlid"] = xml_element.attrib['{http://www.opengis.net/gml}id']

    # set the superordinate feature id
    exec_dict[superordinate_ids[feature_type]] = superordinate_id

    # loop through all top-level children in the element, looking for properties
    for child_element in list(xml_element):

        # loop through feature properties
        # TODO: is this list comprehension stupid?
        for property in [property for property in properties[feature_type] if child_element.tag == "{{http://www.citygml.org/ade/utility/0.9.2}}{0}".format(property) or child_element.tag == "{{http://www.opengis.net/gml}}{0}".format(property)]:
            exec_dict[property] = child_element.text

    # find the geometry relation - it is a special case because it is a relation that doesn't specifically relate to
    # another city object.
    for child_element in [child_element for child_element in list(xml_element) if child_element.tag == "{http://www.citygml.org/ade/utility/0.9.2}lod1Geometry" or child_element.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization"]:
        geom_epsg = process_geom(child_element[0])
        exec_dict["geom"] = geom_epsg[0]
        exec_dict["srid"] = int(geom_epsg[1])

    # find the topograph relation if it is a roundpipe or terminalelement so that we can get the associated featuregraph
    for child_element in [child_element for child_element in list(xml_element) if child_element.tag == "{http://www.citygml.org/ade/utility/0.9.2}topoGraph" and (feature_type == "RoundPipe" or feature_type == "TerminalElement")]:
        if child_element.attrib["{http://www.w3.org/1999/xlink}href"] is not None:
            if child_element.attrib["{http://www.w3.org/1999/xlink}href"][0] == "#":
                xlinked_gmlid = child_element.attrib["{http://www.w3.org/1999/xlink}href"][1:]
            else:
                xlinked_gmlid = child_element.attrib["{http://www.w3.org/1999/xlink}href"]
        featuregraph_id = get_xlink(xlinked_gmlid, cur)
        exec_dict["featuregraph_id"] = featuregraph_id

    # for key in exec_dict:
    #     if exec_dict[key] is not None:
    #         print("{0}: {1}".format(key, exec_dict[key]))

    # we have all the properties now, so insert the feature into database.  get the returned value because it will be
    # id to use as the parent for the next inserted child feature
    query = queries[feature_type]
    print(cur.mogrify(query, exec_dict))
    cur.execute(query, exec_dict)
    last_id_inserted[feature_type] = cur.fetchone()[0]
    print("LAST ID INSERTED {0}".format(last_id_inserted[feature_type]))

    # loop through all top-level children in the element, looking for relations, but excluding the geometry relation
    for child_element in list(xml_element):

        # loop through feature relations
        # TODO: is this list comprehension stupid?
        for relation in [relation for relation in relations[feature_type] if child_element.tag == "{{http://www.citygml.org/ade/utility/0.9.2}}{0}".format(relation) or child_element.tag == "{{http://www.opengis.net/gml}}{0}".format(relation)]:

            if child_element.tag in ALLOWED_RELATIONS:  # TODO: remove temporary allowed relations list

                # check for href
                if "{http://www.w3.org/1999/xlink}href" in child_element.attrib:
                    pass

                    # get the gml id.  it is supposed to be convention to prepend the gml id of an xlink with a "#"
                    # character, but it is not strictly enforced, so we need to handle both cases.
                    if child_element.attrib["{http://www.w3.org/1999/xlink}href"] is not None:
                        if child_element.attrib["{http://www.w3.org/1999/xlink}href"][0] == "#":
                            xlinked_gmlid = child_element.attrib["{http://www.w3.org/1999/xlink}href"][1:]
                        else:
                            xlinked_gmlid = child_element.attrib["{http://www.w3.org/1999/xlink}href"]
                    xlinked_gmlid = get_xlink(xlinked_gmlid, cur)
                    print(xlinked_gmlid)

                else:

                    # recursively call the same function on this element's direct child.
                    #print("RELATION: {0}".format(relation))
                    import_feature(list(child_element)[0], feature_type, last_id_inserted[feature_type], cur)

    return None


def process_geom(xml_geom):

    # get the epsg
    srid = xml_geom.attrib["srsName"][xml_geom.attrib["srsName"].find(":")+1:]

    if xml_geom.tag[xml_geom.tag.find("}") + 1:] == "Point":

        posList = list(xml_geom)[0].text.split(" ")
        geom = "POINT Z (" + (posList[0] + " " + posList[1] + " " + posList[2]) + ")"

    elif xml_geom.tag[xml_geom.tag.find("}")+1:] == "LineString":

        # get the posList child element and split it by spaces, then build it into a WKT string
        posList = list(xml_geom)[0].text.split(" ")
        i = 0
        geom = "LINESTRING Z ("
        while i <= len(posList) - 3:
            geom += (posList[0 + i] + " " + posList[1 + i] + " " + posList[2 + i] + ",")
            i += 3
        geom = geom[:-1] + ")"

    return [geom, srid]


def get_xlink(gmlid, cur):

    """
    Returns the feature from the database with the input gmlid.
    :param gmlid:
    :param cur:
    :return:
    """

    get_id_query = sql.SQL("""
    
        SELECT id FROM citydb.utn9_feature_graph WHERE gmlid = %(gmlid)s
    
    """)

    cur.execute(get_id_query, {"gmlid": gmlid})
    target_id = cur.fetchone()[0]

    return target_id


def link_network_feature_to_featuregraph(ntw_feature_id, featuregraph_id, cur):

    link_query = sql.SQL("""
    
    UPDATE
        citydb.utn9_feature_graph
    SET
        ntw_feature_id = %(ntw_feature_id)s
    WHERE
        id = %(featuregraph_id)s;
    
    """)

    cur.execute(link_query, {"ntw_feature_id": ntw_feature_id, "featuregraph_id": featuregraph_id})

    return None


if __name__ == "__main__":

    citygml = ET.parse("../data/nanaimo_water_pipes.gml")

    conn = psycopg2.connect("host=localhost dbname=unade user=postgres password=postgres")
    #conn.autocommit = True
    cur = conn.cursor()

    test = citygml.findall(".//utility:RoundPipe", ns)

    network = citygml.find(".//utility:Network", ns)

    import_feature(network, None, 0, cur)

    #conn.commit()