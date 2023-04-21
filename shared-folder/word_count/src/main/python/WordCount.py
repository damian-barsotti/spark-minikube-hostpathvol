import sys

from pyspark.sql import SparkSession

file_name = sys.argv[1]

spark = SparkSession.builder.appName("Word Count").getOrCreate()

sc = spark.sparkContext

lines = sc.textFile(file_name)

words = lines \
    .flatMap(lambda line: line.split(" ")) \
    .filter(lambda word: word)

#MapReduce
wordCount = words \
    .map(lambda word: (word,1)) \
    .reduceByKey(lambda n,m: n+m)

result = wordCount \
    .sortBy((lambda p: p[1]), ascending = False) # ordena por cantidad

local_result = result.collect() # Traigo desde cluster

for word, count in local_result[:10]: # tomo 10
    print(word, count) # los imprimo

spark.stop()
