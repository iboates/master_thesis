from psycopg2 import sql

ns = {'utility': "http://www.citygml.org/ade/utility/0.9.2",
          'gml': "http://www.opengis.net/gml"}
booleanmap = {'true': 1,
              'false': 0}

# import time
# print = (lambda p: lambda *args,**kwargs: [p(*args,**kwargs), time.sleep(.01)])(print)

def import_LiquidMedium(liquidmedium, cur):

    liquidmedium_sql_dict = {}

    liquidmedium_gmlid = liquidmedium.attrib['{http://www.opengis.net/gml}id']
    liquidmedium_sql_dict["gmlid"] = liquidmedium_gmlid

    for liquidmedium_child in list(liquidmedium):

        liquidmedium_property = liquidmedium_child.tag[liquidmedium_child.tag.find("}") + 1:]

        # result from FME for isCorrosive & isExplosive will only ever output 'true' or 'false', but DB schema is
        # numeric, so we have to turn these strings into 1 or 0
        if liquidmedium_child.tag == '{http://www.citygml.org/ade/utility/0.9.2}isCorrosive'\
        or liquidmedium_child.tag == '{http://www.citygml.org/ade/utility/0.9.2}isExplosive':
            liquidmedium_sql_dict[liquidmedium_property] = booleanmap[liquidmedium_child.text]
        else:
            liquidmedium_sql_dict[liquidmedium_property] = liquidmedium_child.text

    insert_liquidmedium_sql = sql.SQL("""

            SELECT citydb_view.utn9_insert_commodity_liquid_medium(
                gmlid := %(gmlid)s,
                type := %(type)s,
                is_corrosive := %(isCorrosive)s,
                is_explosive := %(isExplosive)s,
                flammability_ratio := %(flammable)s
            );

        """)

    # print(cur.mogrify(insert_pipe_sql, pipe_sql_dict))
    cur.execute(insert_liquidmedium_sql, liquidmedium_sql_dict)
    liquidmedium_id = cur.fetchone()[0]

    return liquidmedium_id


def import_ElectricalMedium(electricalmedium, cur):

    electricalmedium_sql_dict = {}

    electricalmedium_gmlid = electricalmedium.attrib['{http://www.opengis.net/gml}id']
    electricalmedium_sql_dict["gmlid"] = electricalmedium_gmlid

    for electricalmedium_child in list(electricalmedium):

        electricalmedium_property = electricalmedium_child.tag[electricalmedium_child.tag.find("}") + 1:]

        # result from FME for isCorrosive & isExplosive will only ever output 'true' or 'false', but DB schema is
        # numeric, so we have to turn these strings into 1 or 0
        if electricalmedium_child.tag == '{http://www.citygml.org/ade/utility/0.9.2}isCorrosive' \
                or electricalmedium_child.tag == '{http://www.citygml.org/ade/utility/0.9.2}isExplosive':
            electricalmedium_sql_dict[electricalmedium_property] = booleanmap[electricalmedium_child.text]
        else:
            electricalmedium_sql_dict[electricalmedium_property] = electricalmedium_child.text

    insert_electricalmedium_sql = sql.SQL("""

                SELECT citydb_view.utn9_insert_commodity_electrical_medium(
                    gmlid := %(gmlid)s,
                    type := %(type)s
                );

            """)

    # print(cur.mogrify(insert_pipe_sql, pipe_sql_dict))
    cur.execute(insert_electricalmedium_sql, electricalmedium_sql_dict)
    electricalmedium_id = cur.fetchone()[0]

    return electricalmedium_id


def import_Network(citygml, cur):

    for network in citygml.findall(".//utility:Network",
                                   ns):  # the .// is required if you want to search all children, not just direct children https://stackoverflow.com/questions/9112121/elementtree-findall-returning-empty-list

        network_sql_dict = {}
        insert_networkgraph_sql_dict = {}

        network_gmlid = network.attrib['{http://www.opengis.net/gml}id']
        network_sql_dict["gmlid"] = network_gmlid

        # Add the Network and NetworkGraph before proceeding further, we will need it for linking the components to
        # their featuregraphs.
        for network_child in list(network):

            # Skip the components for now, we need to add the Network and NetworkGraph first.
            if network_child.tag != '{http://www.citygml.org/ade/utility/0.9.2}component':

                if network_child.tag == '{http://www.citygml.org/ade/utility/0.9.2}topoGraph':

                    networkgraph = list(network_child)[0]
                    insert_networkgraph_sql_dict['gmlid'] = networkgraph.attrib['{http://www.opengis.net/gml}id']

                elif network_child.tag == '{http://www.citygml.org/ade/utility/0.9.2}transportedMedium':

                    network_transportedmedium = network_child

                    if list(network_child)[0].tag == '{http://www.citygml.org/ade/utility/0.9.2}LiquidMedium':
                        liquidmedium = list(network_child)[0]
                        network_sql_dict['commodity_id'] = import_LiquidMedium(liquidmedium, cur)

                    elif list(network_transportedmedium)[0].tag == '{http://www.citygml.org/ade/utility/0.9.2}ElectricalMedium':
                        electricalmedium = list(network_transportedmedium)[0]
                        network_sql_dict['commodity_id'] = import_ElectricalMedium(electricalmedium, cur)
                    
                else:

                    network_property = network_child.tag[network_child.tag.find("}") + 1:]
                    network_sql_dict[network_property] = network_child.text

        # ==============================================================================================================
        # INSERT NETWORK
        # ==============================================================================================================

        insert_network_sql = sql.SQL("""

                    SELECT citydb_view.utn9_insert_network(
                        gmlid := %(gmlid)s,
                        function := %(function)s,
                        usage := %(usage)s,
                        commodity_id := %(commodity_id)s,
                        name := %(name)s
                    );

                """)

        # print(cur.mogrify(insert_pipe_sql, pipe_sql_dict))
        cur.execute(insert_network_sql, network_sql_dict)
        network_id = cur.fetchone()[0]

        # ==============================================================================================================
        # INSERT NETWORKGRAPH
        # ==============================================================================================================

        insert_networkgraph_sql = sql.SQL("""

                            SELECT citydb_view.utn9_insert_network_graph(
                                gmlid := %(gmlid)s,
                                network_id := %(network_id)s
                            );

                        """)

        insert_networkgraph_sql_dict['network_id'] = network_id
        # print(cur.mogrify(insert_networkgraph_sql, networkgraph_sql_dict))
        cur.execute(insert_networkgraph_sql, insert_networkgraph_sql_dict)
        networkgraph_id = cur.fetchone()[0]

        # Iterate through and add all of the RoundPipe and TerminalElement elements.
        for network_child in list(network):

            if network_child.tag == '{http://www.citygml.org/ade/utility/0.9.2}component':

                network_component = list(network_child)[0]
                # print("inserting {0}".format(network_component.tag))

                if network_component.tag == '{http://www.citygml.org/ade/utility/0.9.2}RoundPipe':

                    pipe = network_component
                    import_RoundPipe(pipe, networkgraph, cur)

                elif network_component.tag == '{http://www.citygml.org/ade/utility/0.9.2}Cable':

                    cable = network_component
                    import_Cable(cable, networkgraph, cur)

                elif network_component.tag == '{http://www.citygml.org/ade/utility/0.9.2}TerminalElement':

                    terminalelement = network_component
                    import_TerminalElement(terminalelement, networkgraph, cur)

                elif network_component.tag == '{http://www.citygml.org/ade/utility/0.9.2}SimpleFunctionalElement':

                    simplefunctionalelement = network_component
                    import_SimpleFunctionalElement(simplefunctionalelement, networkgraph, cur)

                elif network_component.tag == '{http://www.citygml.org/ade/utility/0.9.2}ControllerDevice':

                    controllerdevice = network_component
                    import_ControllerDevice(controllerdevice, networkgraph, cur)

                elif network_component.tag == '{http://www.citygml.org/ade/utility/0.9.2}StorageDevice':

                    storagedevice = network_component
                    import_StorageDevice(storagedevice, networkgraph, cur)

        # Iterate through the NetworkGraph element to get all of InterFeatureLinks
        for networkgraph_child in list(networkgraph):

            if networkgraph_child.tag == '{http://www.citygml.org/ade/utility/0.9.2}linkMember':
                interfeaturelink = list(networkgraph_child)[0]
                import_InterFeatureLink(interfeaturelink, networkgraph, cur)


def import_RoundPipe(pipe, networkgraph, cur):

    pipe_sql_dict = {}
    featuregraph_sql_dict = {}
    node_sql_dict_list = []
    interiorfeaturelink_sql_dict_list = []

    pipe_gmlid = pipe.attrib['{http://www.opengis.net/gml}id']
    pipe_sql_dict["gmlid"] = pipe_gmlid

    # print("\n\nIMPORTING PIPE {0}".format(pipe_gmlid))

    for pipe_child in list(pipe):

        if pipe_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}lod1Geometry":

            pipe_lod1Geometry = list(pipe_child)[0]
            pipe_lineString = list(pipe_lod1Geometry)[0]
            pipe_points = pipe_lineString.text.split(" ")

            i = 0
            pipe_geom = "LINESTRING Z ("
            while i <= len(pipe_points) - 3:
                pipe_geom += (pipe_points[0 + i] + " " + pipe_points[1 + i] + " " + pipe_points[2 + i] + ",")
                i += 3
            pipe_geom = pipe_geom[:-1] + ")"
            pipe_sql_dict['geom'] = pipe_geom

        elif pipe_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}exteriorDiameter":

            pipe_exteriorDiameter = pipe_child
            pipe_exteriorDiameterUnit = pipe_exteriorDiameter.attrib["uom"]
            pipe_sql_dict['exteriorDiameterUnit'] = pipe_exteriorDiameterUnit

            pipe_sql_dict['exteriorDiameter'] = float(pipe_exteriorDiameter.text)

        # ==========================================================================================================
        # GET FEATUREGRAPH INFO
        # ==========================================================================================================

        elif pipe_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}topoGraph":

            topograph = pipe_child.attrib['{http://www.w3.org/1999/xlink}href'][1:]
            pipe_sql_dict['topoGraph'] = topograph

            featuregraph = networkgraph.findall('.//utility:FeatureGraph[@gml:id="{0}"]'.format(topograph), ns)[0]
            # print("  pipe's featuregraph gmlid: {0}".format(pipe_topoGraph))
            # print("original featuregraph gmlid: {0}".format(featuregraph[0].attrib['{http://www.opengis.net/gml}id']))

            featuregraph_gmlid = featuregraph.attrib['{http://www.opengis.net/gml}id']
            featuregraph_sql_dict["gmlid"] = featuregraph_gmlid

            for featuregraph_child in list(featuregraph):

                # ==================================================================================================
                # GET NODE INFO
                # ==================================================================================================

                if featuregraph_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}nodeMember":

                    nodemember = featuregraph_child
                    node_sql_dict = {
                        'gmlid': 'NULL',
                        'type': 'NULL',
                        'geom': 'NULL',
                    }

                    for nodemember_child in list(nodemember):

                        node = nodemember_child
                        node_gmlid = node.attrib['{http://www.opengis.net/gml}id']
                        node_sql_dict['gmlid'] = node_gmlid

                        for node_child in list(node):

                            if node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}type":

                                node_type = node_child.text
                                node_sql_dict['type'] = node_type

                            elif node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization":

                                realization = node_child
                                node_poslist = list(node_child)[0]
                                point = list(node_poslist)[0].text  # nodes only have a single point as geometry
                                node_geom = "POINT(" + point + ")"
                                node_sql_dict['geom'] = node_geom

                        node_sql_dict_list.append(node_sql_dict)
                        node_sql_dict = node_sql_dict.copy()

                # ==================================================================================================
                # GET INTERIORFEATURELINK INFO
                # ==================================================================================================

                elif featuregraph_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}linkMember":

                    linkmember = featuregraph_child

                    for linkmember_child in list(linkmember):

                        interiorfeaturelink_sql_dict = {
                            'gmlid': 'NULL',
                            'geom': 'NULL',
                            'start_node': 'NULL',
                            'end_node': 'NULL',
                        }

                        interiorfeaturelink = linkmember_child
                        interiorfeaturelink_gmlid = interiorfeaturelink.attrib['{http://www.opengis.net/gml}id']
                        interiorfeaturelink_sql_dict['gmlid'] = interiorfeaturelink_gmlid
                        # print("\t{0}".format(interiorfeaturelink_gmlid))

                        for interiorfeaturelink_child in list(interiorfeaturelink):

                            if interiorfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization":

                                realization = interiorfeaturelink_child
                                realization_linestring = list(realization)[0]
                                realization_points = list(realization_linestring)[0].text.split(" ")

                                i = 0
                                realization_geom = "LINESTRING Z ("
                                while i <= len(realization_points) - 3:
                                    realization_geom += (
                                        realization_points[0 + i] + " " + realization_points[1 + i] + " " +
                                        realization_points[2 + i] + ",")
                                    i += 3
                                realization_geom = realization_geom[:-1] + ")"

                                interiorfeaturelink_sql_dict['geom'] = realization_geom
                                # print("\t\t{0}".format(interiorfeaturelink_sql_dict['geom']))

                            elif interiorfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}start":

                                interiorfeaturelink_start_node = interiorfeaturelink_child.attrib[
                                    '{http://www.w3.org/1999/xlink}href']
                                interiorfeaturelink_sql_dict['start_node'] = interiorfeaturelink_start_node[1:]

                            elif interiorfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}end":

                                interiorfeaturelink_end_node = interiorfeaturelink_child.attrib[
                                    '{http://www.w3.org/1999/xlink}href']
                                interiorfeaturelink_sql_dict['end_node'] = interiorfeaturelink_end_node[1:]

                        interiorfeaturelink_sql_dict_list.append(interiorfeaturelink_sql_dict)
                        interiorfeaturelink_sql_dict = interiorfeaturelink_sql_dict.copy()

        else:

            pipe_property = pipe_child.tag[pipe_child.tag.find("}") + 1:]
            pipe_sql_dict[pipe_property] = pipe_child.text

            # print("ROUNDPIPE:")
            # for key in pipe_sql_dict:
            #     print("{0}: {1}".format(key, pipe_sql_dict[key]))
            # print("\n")
            #
            # print("\tFEATUREGRAPH:")
            # for key in featuregraph_sql_dict:
            #     print("\t{0}: {1}".format(key, featuregraph_sql_dict[key]))
            # print("\n")
            #
            # print("\t\tNODES:")
            # for node_sql_dict in node_sql_dict_list:
            #     for key in node_sql_dict:
            #         print("\t\t{0}: {1}".format(key, node_sql_dict[key]))
            # print("\n")

    # ==============================================================================================================
    # IMPORT PIPE
    # ==============================================================================================================

    insert_pipe_sql = sql.SQL("""

        SELECT citydb_view.utn9_insert_ntw_feat_distrib_elem_pipe_round(
            gmlid := %(gmlid)s,
            function := %(function)s,
            year_of_construction := %(yearOfConstruction)s,
            status := %(status)s,
            location_quality := %(locationQuality)s,
            elevation_quality := %(elevationQuality)s,
            geom := ST_GeomFromText(%(geom)s,26910),
            function_of_line := %(functionOfLine)s,
            ext_diameter := %(exteriorDiameter)s,
            ext_diameter_unit := %(exteriorDiameterUnit)s
        );

    """)

    # print(cur.mogrify(insert_pipe_sql, pipe_sql_dict))
    cur.execute(insert_pipe_sql, pipe_sql_dict)
    pipe_id = cur.fetchone()[0]

    # ==============================================================================================================
    # IMPORT FEATUREGRAPH
    # ==============================================================================================================

    # First we need to get the networkgraph id (not the gmlid)

    networkgraph_id_query = sql.SQL("""
    
        SELECT id from citydb_view.utn9_network_graph WHERE gmlid = %(networkgraph_gmlid)s;
    
    """)

    networkgraph_gmlid = networkgraph.attrib["{http://www.opengis.net/gml}id"]
    cur.execute(networkgraph_id_query, {"networkgraph_gmlid": networkgraph_gmlid})
    networkgraph_id = cur.fetchone()[0]
    featuregraph_sql_dict["ntw_graph_id"] = networkgraph_id

    insert_featuregraph_sql = sql.SQL("""

        SELECT citydb_view.utn9_insert_feature_graph(
            gmlid := %(gmlid)s,
            ntw_feature_id := %(ntw_feature_id)s,
            ntw_graph_id := %(ntw_graph_id)s
        );

    """)

    featuregraph_sql_dict['ntw_feature_id'] = int(pipe_id)
    # print(cur.mogrify(insert_featuregraph_sql, featuregraph_sql_dict))
    cur.execute(insert_featuregraph_sql, featuregraph_sql_dict)
    featuregraph_id = cur.fetchone()[0]

    # ==============================================================================================================
    # IMPORT NODES
    # ==============================================================================================================

    node_id_list = []
    for node_sql_dict in node_sql_dict_list:
        insert_node_sql = sql.SQL("""

            SELECT citydb_view.utn9_insert_node(
                gmlid := %(gmlid)s,
                type := %(type)s,
                feat_graph_id := %(feat_graph_id)s,
                point_geom := ST_GeomFromText(%(geom)s,26910)
            );

        """)

        node_sql_dict["feat_graph_id"] = featuregraph_id
        # print("\nimport node query: {0}".format(cur.mogrify(insert_node_sql, node_sql_dict)))
        cur.execute(insert_node_sql, node_sql_dict)
        node_id_list.append(cur.fetchone()[0])

    # ==============================================================================================================
    # IMPORT INTERIORFEATURELINK
    # ==============================================================================================================

    for interiorfeaturelink_sql_dict in interiorfeaturelink_sql_dict_list:
        # We need the ids of the nodes (NOT THE GMLIDs!)
        # Get the id of the nodes with the corresponding gmlids, which we have

        node_id_query = sql.SQL("""

            SELECT id FROM citydb_view.utn9_node WHERE gmlid = %(node_id)s;

        """)

        start_node_sql_dict = {"node_id": interiorfeaturelink_sql_dict["start_node"]}
        end_node_sql_dict = {"node_id": interiorfeaturelink_sql_dict["end_node"]}

        # print("get start node dict: {0}".format(start_node_sql_dict))
        # print("get end node dict: {0}".format(end_node_sql_dict))

        # print("get start node query: {0}".format(cur.mogrify(node_id_query, start_node_sql_dict)))
        cur.execute(node_id_query, start_node_sql_dict)
        interiorfeaturelink_sql_dict["start_node_id"] = cur.fetchone()[0]
        # print("start node id: {0}".format(interiorfeaturelink_sql_dict["start_node_id"]))

        # print("get end node query: {0}".format(cur.mogrify(node_id_query, end_node_sql_dict)))
        cur.execute(node_id_query, end_node_sql_dict)
        interiorfeaturelink_sql_dict["end_node_id"] = cur.fetchone()[0]
        # print("end node id: {0}".format(interiorfeaturelink_sql_dict["end_node_id"]))

        insert_interiorfeaturelink_sql = sql.SQL("""

            SELECT citydb_view.utn9_insert_link_interior_feature(
                gmlid := %(gmlid)s,
                start_node_id := %(start_node_id)s,
                end_node_id := %(end_node_id)s,
                feat_graph_id := %(feat_graph_id)s,
                line_geom := ST_GeomFromText(%(geom)s,26910)
            );

        """)

        interiorfeaturelink_sql_dict["feat_graph_id"] = featuregraph_id
        # print(cur.mogrify(insert_interiorfeaturelink_sql, interiorfeaturelink_sql_dict))
        cur.execute(insert_interiorfeaturelink_sql, interiorfeaturelink_sql_dict)
        # print("I just inserted an InteriorFeatureLink!")


def import_Cable(cable, networkgraph, cur):
    
    cable_sql_dict = {}
    featuregraph_sql_dict = {}
    node_sql_dict_list = []
    interiorfeaturelink_sql_dict_list = []

    cable_gmlid = cable.attrib['{http://www.opengis.net/gml}id']
    cable_sql_dict["gmlid"] = cable_gmlid

    for cable_child in list(cable):

        if cable_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}lod1Geometry":

            cable_lod1Geometry = list(cable_child)[0]
            cable_lineString = list(cable_lod1Geometry)[0]
            cable_points = cable_lineString.text.split(" ")

            i = 0
            cable_geom = "LINESTRING Z ("
            while i <= len(cable_points) - 3:
                cable_geom += (cable_points[0 + i] + " " + cable_points[1 + i] + " " + cable_points[2 + i] + ",")
                i += 3
            cable_geom = cable_geom[:-1] + ")"
            cable_sql_dict['geom'] = cable_geom

        # ==========================================================================================================
        # GET FEATUREGRAPH INFO
        # ==========================================================================================================

        elif cable_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}topoGraph":

            topograph = cable_child.attrib['{http://www.w3.org/1999/xlink}href'][1:]
            cable_sql_dict['topoGraph'] = topograph

            featuregraph = networkgraph.findall('.//utility:FeatureGraph[@gml:id="{0}"]'.format(topograph), ns)[0]
            # print("  cable's featuregraph gmlid: {0}".format(cable_topoGraph))
            # print("original featuregraph gmlid: {0}".format(featuregraph[0].attrib['{http://www.opengis.net/gml}id']))

            featuregraph_gmlid = featuregraph.attrib['{http://www.opengis.net/gml}id']
            featuregraph_sql_dict["gmlid"] = featuregraph_gmlid

            for featuregraph_child in list(featuregraph):

                # ==================================================================================================
                # GET NODE INFO
                # ==================================================================================================

                if featuregraph_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}nodeMember":

                    nodemember = featuregraph_child
                    node_sql_dict = {
                        'gmlid': 'NULL',
                        'type': 'NULL',
                        'geom': 'NULL',
                    }

                    for nodemember_child in list(nodemember):

                        node = nodemember_child
                        node_gmlid = node.attrib['{http://www.opengis.net/gml}id']
                        node_sql_dict['gmlid'] = node_gmlid

                        for node_child in list(node):

                            if node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}type":

                                node_type = node_child.text
                                node_sql_dict['type'] = node_type

                            elif node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization":

                                realization = node_child
                                node_poslist = list(node_child)[0]
                                point = list(node_poslist)[0].text  # nodes only have a single point as geometry
                                node_geom = "POINT(" + point + ")"
                                node_sql_dict['geom'] = node_geom

                        node_sql_dict_list.append(node_sql_dict)
                        node_sql_dict = node_sql_dict.copy()

                # ==================================================================================================
                # GET INTERIORFEATURELINK INFO
                # ==================================================================================================

                elif featuregraph_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}linkMember":

                    linkmember = featuregraph_child

                    for linkmember_child in list(linkmember):

                        interiorfeaturelink_sql_dict = {
                            'gmlid': 'NULL',
                            'geom': 'NULL',
                            'start_node': 'NULL',
                            'end_node': 'NULL',
                        }

                        interiorfeaturelink = linkmember_child
                        interiorfeaturelink_gmlid = interiorfeaturelink.attrib['{http://www.opengis.net/gml}id']
                        interiorfeaturelink_sql_dict['gmlid'] = interiorfeaturelink_gmlid
                        # print("\t{0}".format(interiorfeaturelink_gmlid))

                        for interiorfeaturelink_child in list(interiorfeaturelink):

                            if interiorfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization":

                                realization = interiorfeaturelink_child
                                realization_linestring = list(realization)[0]
                                realization_points = list(realization_linestring)[0].text.split(" ")

                                i = 0
                                realization_geom = "LINESTRING Z ("
                                while i <= len(realization_points) - 3:
                                    realization_geom += (
                                        realization_points[0 + i] + " " + realization_points[1 + i] + " " +
                                        realization_points[2 + i] + ",")
                                    i += 3
                                realization_geom = realization_geom[:-1] + ")"

                                interiorfeaturelink_sql_dict['geom'] = realization_geom
                                # print("\t\t{0}".format(interiorfeaturelink_sql_dict['geom']))

                            elif interiorfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}start":

                                interiorfeaturelink_start_node = interiorfeaturelink_child.attrib[
                                    '{http://www.w3.org/1999/xlink}href']
                                interiorfeaturelink_sql_dict['start_node'] = interiorfeaturelink_start_node[1:]

                            elif interiorfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}end":

                                interiorfeaturelink_end_node = interiorfeaturelink_child.attrib[
                                    '{http://www.w3.org/1999/xlink}href']
                                interiorfeaturelink_sql_dict['end_node'] = interiorfeaturelink_end_node[1:]

                        interiorfeaturelink_sql_dict_list.append(interiorfeaturelink_sql_dict)
                        interiorfeaturelink_sql_dict = interiorfeaturelink_sql_dict.copy()

        else:

            cable_property = cable_child.tag[cable_child.tag.find("}") + 1:]
            cable_sql_dict[cable_property] = cable_child.text

            # print("ROUNDPIPE:")
            # for key in cable_sql_dict:
            #     print("{0}: {1}".format(key, cable_sql_dict[key]))
            # print("\n")
            #
            # print("\tFEATUREGRAPH:")
            # for key in featuregraph_sql_dict:
            #     print("\t{0}: {1}".format(key, featuregraph_sql_dict[key]))
            # print("\n")
            #
            # print("\t\tNODES:")
            # for node_sql_dict in node_sql_dict_list:
            #     for key in node_sql_dict:
            #         print("\t\t{0}: {1}".format(key, node_sql_dict[key]))
            # print("\n")

    # ==============================================================================================================
    # IMPORT CABLE
    # ==============================================================================================================

    insert_cable_sql = sql.SQL("""

            SELECT citydb_view.utn9_insert_ntw_feat_distrib_elem_cable(
                gmlid := %(gmlid)s,
                function := %(function)s,
                status := %(status)s,
                location_quality := %(locationQuality)s,
                elevation_quality := %(elevationQuality)s,
                geom := ST_GeomFromText(%(geom)s,26910),
                function_of_line := %(functionOfLine)s
            );

        """)

    # print(cur.mogrify(insert_cable_sql, cable_sql_dict))
    cur.execute(insert_cable_sql, cable_sql_dict)
    cable_id = cur.fetchone()[0]

    # ==============================================================================================================
    # IMPORT FEATUREGRAPH
    # ==============================================================================================================

    # First we need to get the networkgraph id (not the gmlid)

    networkgraph_id_query = sql.SQL("""

            SELECT id from citydb_view.utn9_network_graph WHERE gmlid = %(networkgraph_gmlid)s;

        """)

    networkgraph_gmlid = networkgraph.attrib["{http://www.opengis.net/gml}id"]
    cur.execute(networkgraph_id_query, {"networkgraph_gmlid": networkgraph_gmlid})
    networkgraph_id = cur.fetchone()[0]
    featuregraph_sql_dict["ntw_graph_id"] = networkgraph_id

    insert_featuregraph_sql = sql.SQL("""

            SELECT citydb_view.utn9_insert_feature_graph(
                gmlid := %(gmlid)s,
                ntw_feature_id := %(ntw_feature_id)s,
                ntw_graph_id := %(ntw_graph_id)s
            );

        """)

    featuregraph_sql_dict['ntw_feature_id'] = int(cable_id)
    # print(cur.mogrify(insert_featuregraph_sql, featuregraph_sql_dict))
    cur.execute(insert_featuregraph_sql, featuregraph_sql_dict)
    featuregraph_id = cur.fetchone()[0]

    # ==============================================================================================================
    # IMPORT NODES
    # ==============================================================================================================

    node_id_list = []
    for node_sql_dict in node_sql_dict_list:
        insert_node_sql = sql.SQL("""

                SELECT citydb_view.utn9_insert_node(
                    gmlid := %(gmlid)s,
                    type := %(type)s,
                    feat_graph_id := %(feat_graph_id)s,
                    point_geom := ST_GeomFromText(%(geom)s,26910)
                );

            """)

        node_sql_dict["feat_graph_id"] = featuregraph_id
        # print(cur.mogrify(insert_node_sql, node_sql_dict))
        cur.execute(insert_node_sql, node_sql_dict)
        # print("I just inserted a node that got a gmlid of {0}".format(node_sql_dict['gmlid']))
        node_id_list.append(cur.fetchone()[0])

    # ==============================================================================================================
    # IMPORT INTERIORFEATURELINK
    # ==============================================================================================================

    for interiorfeaturelink_sql_dict in interiorfeaturelink_sql_dict_list:
        # We need the ids of the nodes (NOT THE GMLIDs!)
        # Get the id of the nodes with the corresponding gmlids, which we have

        node_id_query = sql.SQL("""

                SELECT id FROM citydb_view.utn9_node WHERE gmlid = %(node_id)s;

            """)

        start_node_sql_dict = {"node_id": interiorfeaturelink_sql_dict["start_node"]}
        end_node_sql_dict = {"node_id": interiorfeaturelink_sql_dict["end_node"]}

        # print(start_node_sql_dict)
        # print(end_node_sql_dict)

        cur.execute(node_id_query, start_node_sql_dict)
        # print("==START NODE==")
        # print(cur.mogrify(node_id_query, start_node_sql_dict))
        interiorfeaturelink_sql_dict["start_node_id"] = cur.fetchone()[0]

        cur.execute(node_id_query, end_node_sql_dict)
        # print("==END NODE==")
        # print(cur.mogrify(node_id_query, end_node_sql_dict))
        interiorfeaturelink_sql_dict["end_node_id"] = cur.fetchone()[0]

        insert_interiorfeaturelink_sql = sql.SQL("""

                SELECT citydb_view.utn9_insert_link_interior_feature(
                    gmlid := %(gmlid)s,
                    start_node_id := %(start_node_id)s,
                    end_node_id := %(end_node_id)s,
                    feat_graph_id := %(feat_graph_id)s,
                    line_geom := ST_GeomFromText(%(geom)s,26910)
                );

            """)

        interiorfeaturelink_sql_dict["feat_graph_id"] = featuregraph_id
        # (cur.mogrify(insert_interiorfeaturelink_sql, interiorfeaturelink_sql_dict))
        cur.execute(insert_interiorfeaturelink_sql, interiorfeaturelink_sql_dict)


def import_TerminalElement(terminalelement, networkgraph, cur):

    # print("inserting terminalelement")

    terminalelement_sql_dict = {}
    featuregraph_sql_dict = {}
    node_sql_dict_list = []

    terminalelement_gmlid = terminalelement.attrib['{http://www.opengis.net/gml}id']
    terminalelement_sql_dict["gmlid"] = terminalelement_gmlid

    for terminalelement_child in list(terminalelement):

        if terminalelement_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}lod1Geometry":

            terminalelement_lod1Geometry = list(terminalelement_child)[0]
            terminalelement_lineString = list(terminalelement_lod1Geometry)[0]
            terminalelement_points = terminalelement_lineString.text.split(" ")

            i = 0
            terminalelement_geom = "POINT Z ("
            while i <= len(terminalelement_points) - 3:
                terminalelement_geom += (
                terminalelement_points[0 + i] + " " + terminalelement_points[1 + i] + " " + terminalelement_points[
                    2 + i] + ",")
                i += 3
            terminalelement_geom = terminalelement_geom[:-1] + ")"
            terminalelement_sql_dict['geom'] = terminalelement_geom

        # ==========================================================================================================
        # GET FEATUREGRAPH INFO
        # ==========================================================================================================

        elif terminalelement_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}topoGraph":

            topograph = terminalelement_child.attrib['{http://www.w3.org/1999/xlink}href'][1:]
            terminalelement_sql_dict['topoGraph'] = topograph

            featuregraph = networkgraph.findall('.//utility:FeatureGraph[@gml:id="{0}"]'.format(topograph), ns)[0]

            featuregraph_gmlid = featuregraph.attrib['{http://www.opengis.net/gml}id']
            featuregraph_sql_dict["gmlid"] = featuregraph_gmlid

            for featuregraph_child in list(featuregraph):

                # ==================================================================================================
                # GET NODE INFO
                # ==================================================================================================

                if featuregraph_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}nodeMember":

                    nodemember = featuregraph_child
                    node_sql_dict = {
                        'gmlid': 'NULL',
                        'type': 'NULL',
                        'geom': 'NULL',
                    }

                    for nodemember_child in list(nodemember):

                        node = nodemember_child
                        node_gmlid = node.attrib['{http://www.opengis.net/gml}id']
                        node_sql_dict['gmlid'] = node_gmlid

                        for node_child in list(node):

                            if node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}type":

                                node_type = node_child.text
                                node_sql_dict['type'] = node_type

                            elif node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization":

                                realization = node_child
                                node_poslist = list(node_child)[0]
                                point = list(node_poslist)[0].text  # nodes only have a single point as geometry
                                node_geom = "POINT(" + point + ")"
                                node_sql_dict['geom'] = node_geom

                        node_sql_dict_list.append(node_sql_dict)
                        node_sql_dict = node_sql_dict.copy()

        else:

            terminalelement_property = terminalelement_child.tag[terminalelement_child.tag.find("}") + 1:]
            terminalelement_sql_dict[terminalelement_property] = terminalelement_child.text

    # ==============================================================================================================
    # IMPORT TERMINALELEMENT
    # ==============================================================================================================

    # TODO: once buildings are added, need to get their id via the connectedCityObject property gml id
    insert_terminalelement_sql = sql.SQL("""

        SELECT citydb_view.utn9_insert_ntw_feat_term_elem(
            gmlid := %(gmlid)s,
            status := %(status)s,
            location_quality := %(locationQuality)s,
            elevation_quality := %(elevationQuality)s,
            /*cityobject_id := %(connectedCityObject)s,*/
            geom := ST_GeomFromText(%(geom)s,26910)
        );

    """)

    #print(terminalelement_sql_dict)
    #print(cur.mogrify(insert_terminalelement_sql, terminalelement_sql_dict))
    cur.execute(insert_terminalelement_sql, terminalelement_sql_dict)
    terminalelement_id = cur.fetchone()[0]

    # ==============================================================================================================
    # IMPORT FEATUREGRAPH
    # ==============================================================================================================

    # First we need to get the networkgraph id (not the gmlid)

    networkgraph_id_query = sql.SQL("""

            SELECT id from citydb_view.utn9_network_graph WHERE gmlid = %(networkgraph_gmlid)s;

        """)

    networkgraph_gmlid = networkgraph.attrib["{http://www.opengis.net/gml}id"]
    cur.execute(networkgraph_id_query, {"networkgraph_gmlid": networkgraph_gmlid})
    networkgraph_id = cur.fetchone()[0]
    featuregraph_sql_dict["ntw_graph_id"] = networkgraph_id

    insert_featuregraph_sql = sql.SQL("""

        SELECT citydb_view.utn9_insert_feature_graph(
            gmlid := %(gmlid)s,
            ntw_feature_id := %(ntw_feature_id)s,
            ntw_graph_id := %(ntw_graph_id)s
        );

    """)

    featuregraph_sql_dict['ntw_feature_id'] = int(terminalelement_id)
    # print(cur.mogrify(insert_featuregraph_sql, featuregraph_sql_dict))
    cur.execute(insert_featuregraph_sql, featuregraph_sql_dict)
    featuregraph_id = cur.fetchone()[0]

    # ==============================================================================================================
    # IMPORT NODES
    # ==============================================================================================================

    node_id_list = []
    for node_sql_dict in node_sql_dict_list:
        insert_node_sql = sql.SQL("""

            SELECT citydb_view.utn9_insert_node(
                gmlid := %(gmlid)s,
                type := %(type)s,
                feat_graph_id := %(feat_graph_id)s,
                point_geom := ST_GeomFromText(%(geom)s,26910)
            );

        """)

        node_sql_dict["feat_graph_id"] = featuregraph_id
        # print(cur.mogrify(insert_node_sql, node_sql_dict))
        cur.execute(insert_node_sql, node_sql_dict)
        node_id_list.append(cur.fetchone()[0])


def import_SimpleFunctionalElement(simplefunctionalelement, networkgraph, cur):
    
    simplefunctionalelement_sql_dict = {}
    featuregraph_sql_dict = {}
    node_sql_dict_list = []

    simplefunctionalelement_gmlid = simplefunctionalelement.attrib['{http://www.opengis.net/gml}id']
    simplefunctionalelement_sql_dict["gmlid"] = simplefunctionalelement_gmlid

    if '{http://www.opengis.net/gml}name' in simplefunctionalelement.attrib.keys():
        simplefunctionalelement_name = simplefunctionalelement.attrib['{http://www.opengis.net/gml}name']
        simplefunctionalelement_sql_dict["name"] = simplefunctionalelement_name
    else:
        simplefunctionalelement_sql_dict["name"] = None

    for simplefunctionalelement_child in list(simplefunctionalelement):

        if simplefunctionalelement_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}lod1Geometry":

            simplefunctionalelement_lod1Geometry = list(simplefunctionalelement_child)[0]
            simplefunctionalelement_lineString = list(simplefunctionalelement_lod1Geometry)[0]
            simplefunctionalelement_points = simplefunctionalelement_lineString.text.split(" ")

            i = 0
            simplefunctionalelement_geom = "POINT Z ("
            while i <= len(simplefunctionalelement_points) - 3:
                simplefunctionalelement_geom += (
                    simplefunctionalelement_points[0 + i] + " " + simplefunctionalelement_points[1 + i] + " " + simplefunctionalelement_points[
                        2 + i] + ",")
                i += 3
            simplefunctionalelement_geom = simplefunctionalelement_geom[:-1] + ")"
            simplefunctionalelement_sql_dict['geom'] = simplefunctionalelement_geom

        # ==========================================================================================================
        # GET FEATUREGRAPH INFO
        # ==========================================================================================================

        elif simplefunctionalelement_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}topoGraph":

            topograph = simplefunctionalelement_child.attrib['{http://www.w3.org/1999/xlink}href'][1:]
            simplefunctionalelement_sql_dict['topoGraph'] = topograph

            featuregraph = networkgraph.findall('.//utility:FeatureGraph[@gml:id="{0}"]'.format(topograph), ns)[0]

            featuregraph_gmlid = featuregraph.attrib['{http://www.opengis.net/gml}id']
            featuregraph_sql_dict["gmlid"] = featuregraph_gmlid

            for featuregraph_child in list(featuregraph):

                # ==================================================================================================
                # GET NODE INFO
                # ==================================================================================================

                if featuregraph_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}nodeMember":

                    nodemember = featuregraph_child
                    node_sql_dict = {
                        'gmlid': 'NULL',
                        'type': 'NULL',
                        'geom': 'NULL',
                    }

                    for nodemember_child in list(nodemember):

                        node = nodemember_child
                        node_gmlid = node.attrib['{http://www.opengis.net/gml}id']
                        node_sql_dict['gmlid'] = node_gmlid

                        for node_child in list(node):

                            if node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}type":

                                node_type = node_child.text
                                node_sql_dict['type'] = node_type

                            elif node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization":

                                realization = node_child
                                node_poslist = list(node_child)[0]
                                point = list(node_poslist)[0].text  # nodes only have a single point as geometry
                                node_geom = "POINT(" + point + ")"
                                node_sql_dict['geom'] = node_geom

                        node_sql_dict_list.append(node_sql_dict)
                        node_sql_dict = node_sql_dict.copy()

        else:

            simplefunctionalelement_property = simplefunctionalelement_child.tag[simplefunctionalelement_child.tag.find("}") + 1:]
            simplefunctionalelement_sql_dict[simplefunctionalelement_property] = simplefunctionalelement_child.text

    # ==============================================================================================================
    # IMPORT SIMPLEFUNCTIONALELEMENT
    # ==============================================================================================================

    # TODO: once buildings are added, need to get their id via the connectedCityObject property gml id
    insert_simplefunctionalelement_sql = sql.SQL("""

            SELECT citydb_view.utn9_insert_ntw_feat_simple_funct_elem(
                gmlid := %(gmlid)s,
                name := %(name)s,
                status := %(status)s,
                geom := ST_GeomFromText(%(geom)s,26910)
            );

        """)

    # print(cur.mogrify(insert_simplefunctionalelement_sql, simplefunctionalelement_sql_dict))
    cur.execute(insert_simplefunctionalelement_sql, simplefunctionalelement_sql_dict)
    simplefunctionalelement_id = cur.fetchone()[0]
    # print("I just inserted a simplefunctionalelement that got an id of {0}".format(simplefunctionalelement_id))

    # ==============================================================================================================
    # IMPORT FEATUREGRAPH
    # ==============================================================================================================

    # First we need to get the networkgraph id (not the gmlid)

    networkgraph_id_query = sql.SQL("""

            SELECT id from citydb_view.utn9_network_graph WHERE gmlid = %(networkgraph_gmlid)s;

        """)

    networkgraph_gmlid = networkgraph.attrib["{http://www.opengis.net/gml}id"]
    cur.execute(networkgraph_id_query, {"networkgraph_gmlid": networkgraph_gmlid})
    networkgraph_id = cur.fetchone()[0]
    featuregraph_sql_dict["ntw_graph_id"] = networkgraph_id

    insert_featuregraph_sql = sql.SQL("""

            SELECT citydb_view.utn9_insert_feature_graph(
                gmlid := %(gmlid)s,
                ntw_feature_id := %(ntw_feature_id)s,
                ntw_graph_id := %(ntw_graph_id)s
            );

        """)

    featuregraph_sql_dict['ntw_feature_id'] = int(simplefunctionalelement_id)
    # print(cur.mogrify(insert_featuregraph_sql, featuregraph_sql_dict))
    cur.execute(insert_featuregraph_sql, featuregraph_sql_dict)
    featuregraph_id = cur.fetchone()[0]
    # print("I just inserted a featuregraph that got an id of {0}".format(featuregraph_id))

    # ==============================================================================================================
    # IMPORT NODES
    # ==============================================================================================================

    node_id_list = []
    for node_sql_dict in node_sql_dict_list:
        insert_node_sql = sql.SQL("""

                SELECT citydb_view.utn9_insert_node(
                    gmlid := %(gmlid)s,
                    type := %(type)s,
                    feat_graph_id := %(feat_graph_id)s,
                    point_geom := ST_GeomFromText(%(geom)s,26910)
                );

            """)

        node_sql_dict["feat_graph_id"] = featuregraph_id
        # print(cur.mogrify(insert_node_sql, node_sql_dict))
        cur.execute(insert_node_sql, node_sql_dict)
        node_id_list.append(cur.fetchone()[0])


def import_ControllerDevice(controllerdevice, networkgraph, cur):
    
    controllerdevice_sql_dict = {}
    featuregraph_sql_dict = {}
    node_sql_dict_list = []

    controllerdevice_gmlid = controllerdevice.attrib['{http://www.opengis.net/gml}id']
    controllerdevice_sql_dict["gmlid"] = controllerdevice_gmlid

    controllerdevice_gmlid = controllerdevice.attrib['{http://www.opengis.net/gml}id']
    controllerdevice_sql_dict["gmlid"] = controllerdevice_gmlid

    for controllerdevice_child in list(controllerdevice):

        if controllerdevice_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}lod1Geometry":

            controllerdevice_lod1Geometry = list(controllerdevice_child)[0]
            controllerdevice_lineString = list(controllerdevice_lod1Geometry)[0]
            controllerdevice_points = controllerdevice_lineString.text.split(" ")

            i = 0
            controllerdevice_geom = "POINT Z ("
            while i <= len(controllerdevice_points) - 3:
                controllerdevice_geom += (
                    controllerdevice_points[0 + i] + " " + controllerdevice_points[1 + i] + " " +
                    controllerdevice_points[
                        2 + i] + ",")
                i += 3
            controllerdevice_geom = controllerdevice_geom[:-1] + ")"
            controllerdevice_sql_dict['geom'] = controllerdevice_geom

        # ==========================================================================================================
        # GET FEATUREGRAPH INFO
        # ==========================================================================================================

        elif controllerdevice_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}topoGraph":

            topograph = controllerdevice_child.attrib['{http://www.w3.org/1999/xlink}href'][1:]
            controllerdevice_sql_dict['topoGraph'] = topograph

            featuregraph = networkgraph.findall('.//utility:FeatureGraph[@gml:id="{0}"]'.format(topograph), ns)[0]

            featuregraph_gmlid = featuregraph.attrib['{http://www.opengis.net/gml}id']
            featuregraph_sql_dict["gmlid"] = featuregraph_gmlid

            for featuregraph_child in list(featuregraph):

                # ==================================================================================================
                # GET NODE INFO
                # ==================================================================================================

                if featuregraph_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}nodeMember":

                    nodemember = featuregraph_child
                    node_sql_dict = {
                        'gmlid': 'NULL',
                        'type': 'NULL',
                        'geom': 'NULL',
                    }

                    for nodemember_child in list(nodemember):

                        node = nodemember_child
                        node_gmlid = node.attrib['{http://www.opengis.net/gml}id']
                        node_sql_dict['gmlid'] = node_gmlid

                        for node_child in list(node):

                            if node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}type":

                                node_type = node_child.text
                                node_sql_dict['type'] = node_type

                            elif node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization":

                                realization = node_child
                                node_poslist = list(node_child)[0]
                                point = list(node_poslist)[0].text  # nodes only have a single point as geometry
                                node_geom = "POINT(" + point + ")"
                                node_sql_dict['geom'] = node_geom

                        node_sql_dict_list.append(node_sql_dict)
                        node_sql_dict = node_sql_dict.copy()

        else:

            controllerdevice_property = controllerdevice_child.tag[
                                               controllerdevice_child.tag.find("}") + 1:]
            controllerdevice_sql_dict[controllerdevice_property] = controllerdevice_child.text

    # ==============================================================================================================
    # IMPORT CONTROLLERDEVICE
    # ==============================================================================================================

    # TODO: once buildings are added, need to get their id via the connectedCityObject property gml id
    insert_controllerdevice_sql = sql.SQL("""

                SELECT citydb_view.utn9_insert_ntw_feat_device_controller(
                    gmlid := %(gmlid)s,
                    class := %(class)s,
                    status := %(status)s,
                    geom := ST_GeomFromText(%(geom)s,26910)
                );

            """)

    # print(cur.mogrify(insert_controllerdevice_sql, controllerdevice_sql_dict))
    cur.execute(insert_controllerdevice_sql, controllerdevice_sql_dict)
    controllerdevice_id = cur.fetchone()[0]
    # print("I just inserted a controllerdevice that got an id of {0}".format(controllerdevice_id))

    # ==============================================================================================================
    # IMPORT FEATUREGRAPH
    # ==============================================================================================================

    # First we need to get the networkgraph id (not the gmlid)

    networkgraph_id_query = sql.SQL("""

            SELECT id from citydb_view.utn9_network_graph WHERE gmlid = %(networkgraph_gmlid)s;

        """)

    networkgraph_gmlid = networkgraph.attrib["{http://www.opengis.net/gml}id"]
    cur.execute(networkgraph_id_query, {"networkgraph_gmlid": networkgraph_gmlid})
    networkgraph_id = cur.fetchone()[0]
    featuregraph_sql_dict["ntw_graph_id"] = networkgraph_id

    insert_featuregraph_sql = sql.SQL("""

                SELECT citydb_view.utn9_insert_feature_graph(
                    gmlid := %(gmlid)s,
                    ntw_feature_id := %(ntw_feature_id)s,
                    ntw_graph_id := %(ntw_graph_id)s
                );

            """)

    featuregraph_sql_dict['ntw_feature_id'] = int(controllerdevice_id)
    # print(cur.mogrify(insert_featuregraph_sql, featuregraph_sql_dict))
    cur.execute(insert_featuregraph_sql, featuregraph_sql_dict)
    featuregraph_id = cur.fetchone()[0]
    # print("I just inserted a featuregraph that got an id of {0}".format(featuregraph_id))

    # ==============================================================================================================
    # IMPORT NODES
    # ==============================================================================================================

    node_id_list = []
    for node_sql_dict in node_sql_dict_list:
        insert_node_sql = sql.SQL("""

                    SELECT citydb_view.utn9_insert_node(
                        gmlid := %(gmlid)s,
                        type := %(type)s,
                        feat_graph_id := %(feat_graph_id)s,
                        point_geom := ST_GeomFromText(%(geom)s,26910)
                    );

                """)

        node_sql_dict["feat_graph_id"] = featuregraph_id
        # print(cur.mogrify(insert_node_sql, node_sql_dict))
        cur.execute(insert_node_sql, node_sql_dict)
        node_id_list.append(cur.fetchone()[0])


def import_StorageDevice(storagedevice, networkgraph, cur):

    storagedevice_sql_dict = {}
    featuregraph_sql_dict = {}
    node_sql_dict_list = []

    storagedevice_gmlid = storagedevice.attrib['{http://www.opengis.net/gml}id']
    storagedevice_sql_dict["gmlid"] = storagedevice_gmlid

    storagedevice_gmlid = storagedevice.attrib['{http://www.opengis.net/gml}id']
    storagedevice_sql_dict["gmlid"] = storagedevice_gmlid

    for storagedevice_child in list(storagedevice):

        if storagedevice_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}lod1Geometry":

            storagedevice_lod1Geometry = list(storagedevice_child)[0]
            storagedevice_lineString = list(storagedevice_lod1Geometry)[0]
            storagedevice_points = storagedevice_lineString.text.split(" ")

            i = 0
            storagedevice_geom = "POINT Z ("
            while i <= len(storagedevice_points) - 3:
                storagedevice_geom += (
                    storagedevice_points[0 + i] + " " + storagedevice_points[1 + i] + " " +
                    storagedevice_points[
                        2 + i] + ",")
                i += 3
            storagedevice_geom = storagedevice_geom[:-1] + ")"
            storagedevice_sql_dict['geom'] = storagedevice_geom

        # ==========================================================================================================
        # GET FEATUREGRAPH INFO
        # ==========================================================================================================

        elif storagedevice_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}topoGraph":

            topograph = storagedevice_child.attrib['{http://www.w3.org/1999/xlink}href'][1:]
            storagedevice_sql_dict['topoGraph'] = topograph

            featuregraph = networkgraph.findall('.//utility:FeatureGraph[@gml:id="{0}"]'.format(topograph), ns)[0]

            featuregraph_gmlid = featuregraph.attrib['{http://www.opengis.net/gml}id']
            featuregraph_sql_dict["gmlid"] = featuregraph_gmlid

            for featuregraph_child in list(featuregraph):

                # ==================================================================================================
                # GET NODE INFO
                # ==================================================================================================

                if featuregraph_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}nodeMember":

                    nodemember = featuregraph_child
                    node_sql_dict = {
                        'gmlid': 'NULL',
                        'type': 'NULL',
                        'geom': 'NULL',
                    }

                    for nodemember_child in list(nodemember):

                        node = nodemember_child
                        node_gmlid = node.attrib['{http://www.opengis.net/gml}id']
                        node_sql_dict['gmlid'] = node_gmlid

                        for node_child in list(node):

                            if node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}type":

                                node_type = node_child.text
                                node_sql_dict['type'] = node_type

                            elif node_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization":

                                realization = node_child
                                node_poslist = list(node_child)[0]
                                point = list(node_poslist)[0].text  # nodes only have a single point as geometry
                                node_geom = "POINT(" + point + ")"
                                node_sql_dict['geom'] = node_geom

                        node_sql_dict_list.append(node_sql_dict)
                        node_sql_dict = node_sql_dict.copy()

        else:

            storagedevice_property = storagedevice_child.tag[
                                        storagedevice_child.tag.find("}") + 1:]
            storagedevice_sql_dict[storagedevice_property] = storagedevice_child.text

    # ==============================================================================================================
    # IMPORT CONTROLLERDEVICE
    # ==============================================================================================================

    # TODO: once buildings are added, need to get their id via the connectedCityObject property gml id
    insert_storagedevice_sql = sql.SQL("""

                    SELECT citydb_view.utn9_insert_ntw_feat_device_storage(
                        gmlid := %(gmlid)s,
                        class := %(class)s,
                        status := %(status)s,
                        geom := ST_GeomFromText(%(geom)s,26910)
                    );

                """)

    # print(cur.mogrify(insert_storagedevice_sql, storagedevice_sql_dict))
    cur.execute(insert_storagedevice_sql, storagedevice_sql_dict)
    storagedevice_id = cur.fetchone()[0]
    # print("I just inserted a storagedevice that got an id of {0}".format(storagedevice_id))

    # ==============================================================================================================
    # IMPORT FEATUREGRAPH
    # ==============================================================================================================

    # First we need to get the networkgraph id (not the gmlid)

    networkgraph_id_query = sql.SQL("""

            SELECT id from citydb_view.utn9_network_graph WHERE gmlid = %(networkgraph_gmlid)s;

        """)

    networkgraph_gmlid = networkgraph.attrib["{http://www.opengis.net/gml}id"]
    cur.execute(networkgraph_id_query, {"networkgraph_gmlid": networkgraph_gmlid})
    networkgraph_id = cur.fetchone()[0]
    featuregraph_sql_dict["ntw_graph_id"] = networkgraph_id

    insert_featuregraph_sql = sql.SQL("""

                    SELECT citydb_view.utn9_insert_feature_graph(
                        gmlid := %(gmlid)s,
                        ntw_feature_id := %(ntw_feature_id)s,
                        ntw_graph_id := %(ntw_graph_id)s
                    );

                """)

    featuregraph_sql_dict['ntw_feature_id'] = int(storagedevice_id)
    # print(cur.mogrify(insert_featuregraph_sql, featuregraph_sql_dict))
    cur.execute(insert_featuregraph_sql, featuregraph_sql_dict)
    featuregraph_id = cur.fetchone()[0]
    # print("I just inserted a featuregraph that got an id of {0}".format(featuregraph_id))

    # ==============================================================================================================
    # IMPORT NODES
    # ==============================================================================================================

    node_id_list = []
    for node_sql_dict in node_sql_dict_list:
        insert_node_sql = sql.SQL("""

                        SELECT citydb_view.utn9_insert_node(
                            gmlid := %(gmlid)s,
                            type := %(type)s,
                            feat_graph_id := %(feat_graph_id)s,
                            point_geom := ST_GeomFromText(%(geom)s,26910)
                        );

                    """)

        node_sql_dict["feat_graph_id"] = featuregraph_id
        # print(cur.mogrify(insert_node_sql, node_sql_dict))
        cur.execute(insert_node_sql, node_sql_dict)
        node_id_list.append(cur.fetchone()[0])


def import_InterFeatureLink(interfeaturelink, networkgraph, cur):

    interfeaturelink_sql_dict = {}

    interfeaturelink_gmlid = interfeaturelink.attrib['{http://www.opengis.net/gml}id']
    interfeaturelink_sql_dict["gmlid"] = interfeaturelink_gmlid
    # print("attempting to import intefeaturelink #{0}".format(interfeaturelink_gmlid))

    for interfeaturelink_child in list(interfeaturelink):

        if interfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}realization":

            realization = interfeaturelink_child
            realization_linestring = list(realization)[0]
            realization_points = list(realization_linestring)[0].text.split(" ")

            i = 0
            realization_geom = "LINESTRING Z ("
            while i <= len(realization_points) - 3:
                realization_geom += (
                    realization_points[0 + i] + " " + realization_points[1 + i] + " " +
                    realization_points[2 + i] + ",")
                i += 3
            realization_geom = realization_geom[:-1] + ")"

            interfeaturelink_sql_dict['geom'] = realization_geom

        elif interfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}start":

            interfeaturelink_start_node = interfeaturelink_child.attrib['{http://www.w3.org/1999/xlink}href']
            interfeaturelink_sql_dict['start_node'] = interfeaturelink_start_node[1:]

        elif interfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}end":

            interfeaturelink_end_node = interfeaturelink_child.attrib['{http://www.w3.org/1999/xlink}href']
            interfeaturelink_sql_dict['end_node'] = interfeaturelink_end_node[1:]

        elif interfeaturelink_child.tag == "{http://www.citygml.org/ade/utility/0.9.2}type":

            interfeaturelink_type = interfeaturelink_child
            interfeaturelink_sql_dict['type'] = interfeaturelink_type.text

    # We need the ids of the nodes (NOT THE GMLIDs!)
    # Get the id of the nodes with the corresponding gmlids, which we have

    node_id_query = sql.SQL("""

        SELECT id FROM citydb_view.utn9_node WHERE gmlid = %(node_id)s;

    """)

    start_node_sql_dict = {"node_id": interfeaturelink_sql_dict["start_node"]}
    end_node_sql_dict = {"node_id": interfeaturelink_sql_dict["end_node"]}

    # print(cur.mogrify(node_id_query, end_node_sql_dict))
    cur.execute(node_id_query, start_node_sql_dict)
    interfeaturelink_sql_dict["start_node_id"] = cur.fetchone()[0]

    # print(cur.mogrify(node_id_query, end_node_sql_dict))
    cur.execute(node_id_query, end_node_sql_dict)
    interfeaturelink_sql_dict["end_node_id"] = cur.fetchone()[0]

    insert_interfeaturelink_sql = sql.SQL("""

        SELECT citydb_view.utn9_insert_link_interfeature(
            gmlid := %(gmlid)s,
            start_node_id := %(start_node_id)s,
            end_node_id := %(end_node_id)s,
            ntw_graph_id := %(ntw_graph_id)s,
            line_geom := ST_GeomFromText(%(geom)s,26910)
        );

    """)

    #  Remove null geometries
    if "geom" not in interfeaturelink_sql_dict:
        interfeaturelink_sql_dict["geom"] = None

    # We need to get the networkgraph id (not the gmlid)

    networkgraph_id_query = sql.SQL("""

            SELECT id from citydb_view.utn9_network_graph WHERE gmlid = %(networkgraph_gmlid)s;

        """)

    networkgraph_gmlid = networkgraph.attrib["{http://www.opengis.net/gml}id"]
    cur.execute(networkgraph_id_query, {"networkgraph_gmlid": networkgraph_gmlid})
    networkgraph_id = cur.fetchone()[0]
    interfeaturelink_sql_dict["ntw_graph_id"] = networkgraph_id

    # print(cur.mogrify(insert_interfeaturelink_sql, interfeaturelink_sql_dict))
    cur.execute(insert_interfeaturelink_sql, interfeaturelink_sql_dict)
