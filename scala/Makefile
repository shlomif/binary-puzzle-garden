# Makefile for the Scala version of binary-puzzle-garden.
#
# Available under http://opensource.org/licenses/mit-license.php .
#
# Copyright by Shlomi Fish, 2012

CLASSES = ExampleSuite.class

all: $(CLASSES)

ExampleSuite.class: %.class: %.scala
	scalac -cp scalatest_2.9.0-2.0.M3.jar $<

test: all
	scala -cp scalatest_2.9.0-2.0.M3.jar org.scalatest.run ExampleSuite
