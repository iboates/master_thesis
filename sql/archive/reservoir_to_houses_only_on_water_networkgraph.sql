/* Drop the table if it exists */
DROP TABLE IF EXISTS public.nanaimo_reservoir_to_houses_water;

CREATE TABLE public.nanaimo_reservoir_to_houses_water AS (

	/* house_node_id will indicate which house is the destination of the returned set of links.
	   link_id is the id of the each (interior or inter). geom is necessary for visualization in QGIS. */
	SELECT
		end_vid AS house_node_id,
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
					citydb.utn9_feature_graph AS fg
				WHERE
					(
						(l.feat_graph_id = fg.id
						AND
						fg.ntw_graph_id = 28 /* water */)
						OR
						(l.ntw_graph_id = 28)
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
					citydb.utn9_feature_graph AS fg
				WHERE
					(
						(l.feat_graph_id = fg.id
						AND
						fg.ntw_graph_id = 28 /* water */)
						OR
						(l.ntw_graph_id = 28)
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
							citydb.utn9_node AS n,
							citydb.utn9_feature_graph AS fg,
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
						    citydb.utn9_node AS n,
						    citydb.utn9_feature_graph AS fg,
						    citydb.utn9_network_feature AS nf
						WHERE
						    nf.status = ''outOfService''
						    AND
						    n.feat_graph_id = fg.id
						    AND
						    fg.ntw_feature_id = nf.id)',
				
			/* Use the node from the only entry in the "Storage Device" table as a source node. */
			(SELECT
				n.id AS id
			FROM
				citydb_view.utn9_ntw_feat_device_storage AS sd,
				citydb_view.utn9_node AS n,
				citydb_view.utn9_feature_graph AS fg
			WHERE
				n.feat_graph_id = fg.id
				AND
				fg.ntw_feature_id = sd.id
				AND
				fg.ntw_graph_id = 28),

			/* Use all the nodes from the entries in the "Terminal Element" table as target nodes. */
			(SELECT
				array_agg(n.id) AS id
			FROM
				citydb_view.utn9_ntw_feat_term_elem AS te,
				citydb_view.utn9_node AS n,
				citydb_view.utn9_feature_graph AS fg
			WHERE
				n.feat_graph_id = fg.id
				AND
				fg.ntw_feature_id = te.id
				AND
				fg.ntw_graph_id = 28)
		)
	AS sr,
	citydb.utn9_link AS l

	/* Join the link information to the routing result to get its geometry & id (ignore those without geometry). */
	WHERE
		l.line_geom IS NOT NULL
		AND
		l.id = sr.edge
		
);