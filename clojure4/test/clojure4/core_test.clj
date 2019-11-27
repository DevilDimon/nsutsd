(ns clojure4.core-test
  (:require [clojure.test :refer :all]
            [clojure4.core :refer :all]
            [clojure4.core :as c]))

(deftest simple-test
  (testing "A ==> A"
    (is (= '(::c/var :a))
        (dnf (variable :a))))
  (testing "Single conjunction"
    (is (= '(::c/and (::c/var :a) (::c/var :b))
           (dnf (conjunction (variable :a) (variable :b))))))
  (testing "Single conjunction with var"
    (is (= '(::c/or (::c/and (::c/var :a) (::c/var :b)) (::c/var :c))
           (dnf (disjunction (conjunction (variable :a) (variable :b)) (variable :c))))))
  (testing "Two large conjunctions"
    (is (= '(::c/or (::c/and (::c/var :a) (::c/and (::c/not (::c/var :b)) (::c/not (::c/var :c))))
              (::c/and (::c/not (::c/var :d)) (::c/and (::c/var :e) (::c/var :f))))
           (dnf (disjunction
                  (conjunction (variable :a)
                               (conjunction (negation (variable :b)) (negation (variable :c))))
                  (conjunction (negation (variable :d))
                               (conjunction (variable :e) (variable :f))))))))
  (testing "Many conjunctions"
    (is (= '(::c/or (::c/and (::c/var :a) (::c/and (::c/var :b) (::c/not (::c/var :c))))
              (::c/or (::c/and (::c/not (::c/var :d)) (::c/and (::c/var :e) (::c/var :f)))
                (::c/or (::c/and (::c/var :c) (::c/var :d)) (::c/var :b))))
           (dnf (disjunction
                  (conjunction (variable :a) (conjunction (variable :b) (negation (variable :c))))
                  (disjunction
                    (conjunction (negation (variable :d)) (conjunction (variable :e) (variable :f)))
                    (disjunction (conjunction (variable :c) (variable :d)) (variable :b)))))))))

(deftest simple-subsumption-test
  (is (= '(::c/const false) (final-dnf (constant false))))
  (is (= '(::c/const true) (final-dnf (constant true))))
  (is (= '(::c/var :a) (final-dnf (variable :a))))
  (is (= '(::c/not (::c/var :a)) (final-dnf (negation (variable :a)))))
  (is (= '(::c/or-mult (::c/var :a) (::c/var :b) (::c/var :c))
         (final-dnf (disjunction (variable :a) (disjunction (variable :b) (variable :c))))))
  (is (= '(::c/and-mult (::c/var :a) (::c/var :b) (::c/var :c))
         (final-dnf (conjunction (variable :a) (conjunction (variable :b) (variable :c)))))))

(deftest negation-test
  (is (= '(::c/var :a) (final-dnf (negation (negation (variable :a))))))
  (is (= '(::c/and-mult (::c/var :a) (::c/not (::c/var :b)))
         (final-dnf (negation (implication (variable :a) (variable :b))))))
  (is (= '(::c/or-mult
            (::c/and-mult (::c/not (::c/var :a)) (::c/not (::c/var :b)) (::c/var :x))
            (::c/and-mult (::c/not (::c/var :a)) (::c/not (::c/var :b)) (::c/var :y)))
         (final-dnf (negation (implication (negation (disjunction (variable :a) (variable :b)))
                                           (negation (disjunction (variable :x) (variable :y))))))))
  (is (= '(::c/or-mult (::c/not (::c/var :a)) (::c/not (::c/var :b)) (::c/var :x) (::c/var :y))
         (final-dnf (negation
                      (conjunction (variable :a)
                                   (conjunction (variable :b)
                                                (conjunction (negation (variable :x)) (negation (variable :y)))))))))
  (is (= '(::c/and-mult (::c/not (::c/var :a)) (::c/not (::c/var :b)) (::c/var :x) (::c/var :y))
         (final-dnf (negation
                      (disjunction (variable :a)
                                   (disjunction (variable :b)
                                                (disjunction (negation (variable :x)) (negation (variable :y))))))))))

(deftest implication-test
  (testing "Simple implication"
    (is (= '(::c/or (::c/not (::c/var :a)) (::c/var :b))
           (dnf (implication (variable :a) (variable :b))))))
  (testing "Inner implication"
    (is (= '(::c/or (::c/not (::c/var :a)) (::c/or (::c/not (::c/var :b)) (::c/var :c)))
           (dnf (implication (variable :a) (implication (variable :b) (variable :c))))))))

(deftest complex-test
  (testing "Double implication with disjunction"
    (is (= '(::c/or
              (::c/and (::c/var :x) (::c/not (::c/var :y)))
              (::c/and (::c/var :x)
                (::c/and (::c/not (::c/var :y)) (::c/var :z))))
           (dnf (negation (disjunction (implication (variable :x) (variable :y))
                                                          (negation (implication (variable :y) (variable :z))))))))))

(deftest multiple-transformation-test
  (testing "Complex multiple transformation"
    (is (= '(::c/or-mult
              (::c/var :b)
              (::c/and-mult (::c/var :a) (::c/var :b) (::c/not (::c/var :c)))
              (::c/and-mult (::c/not (::c/var :d)) (::c/var :e) (::c/var :f))
              (::c/and-mult (::c/var :c) (::c/var :d)))
           (transform-to-mult (disjunction
                                (conjunction (variable :a) (conjunction (variable :b) (negation (variable :c))))
                                (disjunction
                                  (conjunction (negation (variable :d)) (conjunction (variable :e) (variable :f)))
                                  (disjunction (conjunction (variable :c) (variable :d)) (variable :b))))))))
  (testing "Simpler recursive conjunction"
    (is (= '(::c/and-mult (::c/const false) (::c/var :a) (::c/not (::c/var :b)))
           (transform-to-mult (conjunction
                                (conjunction (constant true) (constant false))
                                (conjunction
                                  (conjunction (variable :a) (negation (variable :b))) (negation (variable :b))))))))
  (testing "Simple oneway single-variable disjunction chain"
    (is (= '(::c/var :a)
           (transform-to-mult (disjunction (variable :a) (disjunction (variable :a) (disjunction (variable :a) (variable :a)))))))))

(deftest evaluation-test
  (is (= '(::c/const false)
         (final-dnf (conjunction
                      (disjunction (variable :p) (disjunction (variable :q) (variable :r)))
                      (disjunction (negation (variable :p)) (negation (variable :q))))
                    {:p true, :q true, :r false}))))