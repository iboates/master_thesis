DROP TABLE IF EXISTS public.nanaimo_route_result;

CREATE TABLE public.nanaimo_route_result AS (
	SELECT
		r.edge AS edge_id,
		l.gmlid AS gml_id,
		l.line_geom AS geom
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
			217,
			391
	)
	AS
		r
	INNER JOIN
		citydb.utn9_link AS l
	ON
		l.id = r.edge
	WHERE
		l.line_geom IS NOT NULL
);