# Makefile for the Scala version of binary-puzzle-garden.
#
# Available under http://opensource.org/licenses/mit-license.php .
#
# Copyright by Shlomi Fish, 2012

CLASSES = ExampleSuite.class

SCALA_TEST_JAR = scalatest_2.9.0-2.0.M3.jar

all: $(SCALA_TEST_JAR) $(CLASSES)

ExampleSuite.class: %.class: %.scala $(SCALA_TEST_JAR)
	scalac -cp $(SCALA_TEST_JAR) $<

test: all $(SCALA_TEST_JAR)
	scala -cp $(SCALA_TEST_JAR) org.scalatest.run ExampleSuite
