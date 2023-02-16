import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.SaveMode

object WordCount {

  def main(args: Array[String]) {

    //  Logger.getLogger("info").setLevel(Level.OFF)

    if (args.length != 2) {
      Console.err.println(s"Given ${args.length} arguments. ${args.toList}")
      Console.err.println("Need two arguments: <file in> <file out>")
      sys.exit(1)
    }

    val fIn = args(0)
    val fOut = args(1)

    val spark = SparkSession
      .builder()
      .appName("Word Count")
      .config("spark.some.config.option", "algun-valor")
      .getOrCreate()

    import spark.implicits._

    val sc = spark.sparkContext

    sc.setLogLevel("WARN")

    val lines = sc.textFile(fIn)

    println("Cantidad de tareas/particiones: " + lines.partitions.size)

    val words = lines
                .flatMap(l => l.split(" "))
                .filter(l => ! l.isEmpty)

    //MapReduce
    val wordCount = words.map(x => (x,1))
                    .reduceByKey((nx,ny) => nx+ny)

    // ordena por cantidad
    val result = wordCount.sortBy((p => p._2), ascending = false)

    result.toDS.write.mode(SaveMode.Overwrite).csv(fOut)
  }
}
