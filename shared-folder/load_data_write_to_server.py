from pyspark.sql import SparkSession #Spark Session
from pyspark.sql import DataFrame
import os
import sys

if __name__ == "__main__":
    # Crear spark session

    script_path = os.path.abspath(os.path.dirname(sys.argv[0]))
    print("Running dir:", script_path)

    FILE_CSV = f"/shared-folder/airports.csv"
    DELIMITER = ","

    spark = SparkSession.builder \
    .appName("API Spark") \
    .enableHiveSupport() \
    .getOrCreate()

    spark.sparkContext.setLogLevel('WARN')

    #print(os.getcwd())
    #os.exit()

    # Leer archivo


    df = spark.read.load(FILE_CSV,format="csv", delimiter=DELIMITER, header=True, inferSchema=True)

    print("Number of partitionss:", df.rdd.getNumPartitions())
    print("Default RDD parallelism:", spark.sparkContext.defaultParallelism)

    df.show()

    # Write to server
    df.write.mode("overwrite").saveAsTable("airports")

    spark.sql("select * from airports").show()
