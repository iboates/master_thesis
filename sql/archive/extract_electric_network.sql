DROP TABLE IF EXISTS electrical_topo.electric_network;

CREATE TABLE electrical_topo.electric_network AS (
	SELECT DISTINCT ON (te.id)
		te.id AS id,
		'houseServiceLine'::TEXT AS type,
		ST_ShortestLine(r.geom, te.geom) AS geom
	FROM
		electrical_topo.roads AS r,
		citydb_view.utn9_ntw_feat_term_elem AS te
	ORDER BY
		te.id,
		ST_Distance(r.geom, te.geom)
);

INSERT INTO
	electrical_topo.electric_network
SELECT
	r.id AS id,
	'mainLine'::TEXT AS type,
	ST_Intersection(r.geom, ST_Buffer(c.geom, 10)) AS geom
FROM
	electrical_topo.roads AS r,
	electrical_topo.clipper AS c;