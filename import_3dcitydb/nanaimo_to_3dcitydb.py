import xml.etree.ElementTree as ET
import psycopg2
from src.UtilityNetworkADE2DB import import_Network


if __name__ == "__main__":

<<<<<<< HEAD
    conn = psycopg2.connect("host=eif-pg-96-01 dbname=isaac_thesis user=isaac_thesis_serviceaccount password=z23jIfZXKaoUrG8F")
    # conn = psycopg2.connect("host=localhost dbname=unade user=postgres password=postgres")
=======
#     conn = psycopg2.connect("host=localhost dbname=unade user=postgres password=postgres")
    conn = psycopg2.connect("host=eif-pg-96-01 dbname=isaac_thesis user=isaac_thesis_serviceaccount password=z23jIfZXKaoUrG8F")
>>>>>>> dev

    # conn.autocommit = True

    cur = conn.cursor()

    # citygml = ET.parse('/media/isaac/Data/_GMCM/Thesis/data/citygml/nanaimo_water_network.gml')
    # citygml = ET.parse('/media/isaac/Data/_GMCM/Thesis/data/citygml/nanaimo_electric_network.gml')
    citygml = ET.parse('../data/citygml/nanaimo_water_and_electric_network.gml')

    import_Network(citygml, cur)

    conn.commit()
