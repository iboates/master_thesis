DROP TABLE IF EXISTS public.nanaimo_stress_result;

CREATE TABLE public.nanaimo_stress_result AS (
	SELECT
		l.id AS id, 
		SUM(sr.cost) AS stress,
		l.line_geom AS geom
	FROM
		pgr_dijkstra(
			'SELECT
				id,
				start_node_id AS source,
				end_node_id AS target,
				cost,
				reverse_cost
			FROM (
				/* Just want to count the number of traversals for each link, so use cost=1. */
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
					citydb.utn9_link AS l
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
				n.feat_graph_id = fg.id AND fg.ntw_feature_id = sd.id),

			/* Use all the nodes from the entries in the "Terminal Element" table as target nodes. */
			(SELECT
				array_agg(n.id) AS id
			FROM
				citydb_view.utn9_ntw_feat_term_elem AS te,
				citydb_view.utn9_node AS n,
				citydb_view.utn9_feature_graph AS fg
			WHERE
				n.feat_graph_id = fg.id AND fg.ntw_feature_id = te.id)
		)
	AS sr,
	citydb.utn9_link AS l

	/* Join the returned edges to the links, and only keep the ones that have a geometry (for visualization) */
	WHERE
		l.line_geom IS NOT NULL
		AND
		l.id = sr.edge
	GROUP BY
		l.id, l.line_geom
		
);