DROP TABLE IF EXISTS public.nanaimo_stress_result;

CREATE TABLE public.nanaimo_stress_result AS (
	SELECT
		edge AS id,
		SUM(cost) AS stress,
		line_geom AS geom
	FROM
		pgr_dijkstra(
			'SELECT
				id,
				start_node_id AS source,
				end_node_id AS target,
				cost,
				reverse_cost
			FROM
				public.nanaimo_routing',
			103312,
			(SELECT
				array_agg(n.id) AS id
				-- te.gmlid AS terminalelement_gmlid,
				-- fg.gmlid AS featuregraph_gmlid,
				-- n.gmlid AS node_gmlid
			FROM
				citydb_view.utn9_ntw_feat_term_elem AS te,
				citydb_view.utn9_node AS n,
				citydb_view.utn9_feature_graph AS fg
			WHERE
				n.feat_graph_id = fg.id AND fg.ntw_feature_id = te.id)
		)
	AS
		sr
	INNER JOIN
		citydb.utn9_link AS l
	ON
		l.id = sr.edge
	WHERE
		l.line_geom IS NOT NULL
	GROUP BY
		edge, line_geom
);