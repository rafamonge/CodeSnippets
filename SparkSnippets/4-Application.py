import sys
from pyspark import SparkContext
from pyspark import SparkConf

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print >> sys.stderr, "Usage: CountJPGs <file>"
        exit(-1)
        
    sc = SparkContext()
    # Challenge: Configure app name and UI port programatically
    # sconf = SparkConf().setAppName("My Spark App").set("spark.ui.port","4444")
    # sc = SparkContext(conf=sconf)
    logfile = sys.argv[1]
    count = sc.textFile(logfile).filter(lambda line: '.jpg' in line).count()
    print "Number of JPG requests: ", count
    sc.stop()