DROP TABLE IF EXISTS public.nanaimo_routing;

CREATE TABLE public.nanaimo_routing AS (

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
	WHERE
		oc.id = l.objectclass_id

);

DROP TABLE IF EXISTS public.nanaimo_network_volume;

CREATE TABLE public.nanaimo_network_volume AS (
	SELECT
		l.id AS id,
		rp.ext_diameter AS diameter,
		l.line_geom AS geom
	FROM
		pgr_drivingDistance(

			/* NETWORK GRAPH FOR PGROUTING */
			'SELECT
				id,
				start_node_id AS source,
				end_node_id AS target,
				cost,
				reverse_cost
			FROM
				public.nanaimo_routing

			/* EXCLUDE LINKS THAT COME FROM A FEATURE THAT IS status=''outOfService'' */
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

			/* START NODE (RESERVOIR) */
			(SELECT
				n.id AS id
			FROM
				citydb_view.utn9_ntw_feat_device_storage AS sd,
				citydb_view.utn9_node AS n,
				citydb_view.utn9_feature_graph AS fg
			WHERE
				n.feat_graph_id = fg.id AND fg.ntw_feature_id = sd.id),

			/* MAX "DISTANCE" */
			100
			
		) AS sr,
		citydb.utn9_link AS l,
		citydb_view.utn9_ntw_feat_distrib_elem_pipe_round AS rp
	WHERE
		l.id = sr.edge
		AND
		rp.ext_diameter != 0
);