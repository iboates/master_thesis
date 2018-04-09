/* Drop the table if it exists */
DROP TABLE IF EXISTS public.nanaimo_routing_elec;

CREATE TABLE public.nanaimo_routing_elec AS (

	/* house_node_id will indicate which house is the destination of the returned set of links.
	   link_id is the id of the each (interior or inter). geom is necessary for visualization in QGIS. */
	SELECT
		edge AS link_id,
		line_geom AS geom
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

				SELECT
					oc.classname,
					l.ntw_graph_id,
					l.feat_graph_id,
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
					net.name = ''Electric Network''
					AND
					ng.network_id = net.id
					AND
					oc.id = l.objectclass_id
					AND
					l.ntw_graph_id = ng.id

				UNION ALL

				SELECT
					oc.classname,
					l.ntw_graph_id,
					NULL AS feat_graph_id,
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
					citydb.utn9_feature_graph AS fg,
					citydb_view.utn9_network AS net,
					citydb_view.utn9_network_graph AS ng
				WHERE
					net.name = ''Electric Network''
					AND
					ng.network_id = net.id
					AND
					l.feat_graph_id IS NOT NULL
					AND
					oc.id = l.objectclass_id
					AND
					l.feat_graph_id = fg.id
					AND
					fg.ntw_graph_id = ng.id

			) AS graph',

			/* Use the node from the only entries in the "Simple Functional Eleent" view as source nodes. */
			(SELECT
				array_agg(n.id) AS id
			FROM
				citydb_view.utn9_ntw_feat_simple_funct_elem AS sfe,
				citydb_view.utn9_node AS n,
				citydb_view.utn9_feature_graph AS fg,
				citydb_view.utn9_network AS net,
				citydb_view.utn9_network_graph AS ng
			WHERE
				net.name = 'Electric Network'
				AND
				ng.network_id = net.id
				AND
				n.feat_graph_id = fg.id
				AND
				fg.ntw_feature_id = sfe.id
				AND
				fg.ntw_graph_id = ng.id),

			/* Use all the nodes from the entries in the "Terminal Element" view as target nodes. */
			(SELECT
				array_agg(n.id) AS id
			FROM
				citydb_view.utn9_ntw_feat_term_elem AS te,
				citydb_view.utn9_feature_graph AS fg,
				citydb_view.utn9_node AS n,
				citydb_view.utn9_network AS net,
				citydb_view.utn9_network_graph AS ng
			WHERE
				net.name = 'Electric Network'
				AND
				ng.network_id = net.id
				AND
				fg.ntw_feature_id = te.id
				AND
				fg.ntw_graph_id = ng.id
				AND
				n.feat_graph_id = fg.id)
		)
	AS sr,
	citydb.utn9_link AS l

	/* Join the link information to the routing result to get its geometry & id (ignore those without geometry). */
	WHERE
		l.line_geom IS NOT NULL
		AND
		l.id = sr.edge
		
);