
(declare-fun sx () Int)
(declare-fun sy () Int)
(declare-fun sz () Int)
(declare-fun svx () Int)
(declare-fun svy () Int)
(declare-fun svz () Int)

(declare-fun t_0 () Int)
(assert (= (+ 181562673221791 (* 54 t_0)) (+ sx (* svx t_0))))
(assert (= (+ 338272173381384 (* -10 t_0)) (+ sy (* svy t_0))))
(assert (= (+ 367757712264029 (* -10 t_0)) (+ sz (* svz t_0))))
(declare-fun t_1 () Int)
(assert (= (+ 206315329209944 (* 55 t_1)) (+ sx (* svx t_1))))
(assert (= (+ 245384073975106 (* 100 t_1)) (+ sy (* svy t_1))))
(assert (= (+ 327941392745372 (* 14 t_1)) (+ sz (* svz t_1))))
(declare-fun t_2 () Int)
(assert (= (+ 197625997051112 (* 13 t_2)) (+ sx (* svx t_2))))
(assert (= (+ 364791147875511 (* -27 t_2)) (+ sy (* svy t_2))))
(assert (= (+ 421084289548856 (* -52 t_2)) (+ sz (* svz t_2))))
(declare-fun t_3 () Int)
(assert (= (+ 335607631675402 (* -91 t_3)) (+ sx (* svx t_3))))
(assert (= (+ 372977327877226 (* -180 t_3)) (+ sy (* svy t_3))))
(assert (= (+ 443503801516025 (* -307 t_3)) (+ sz (* svz t_3))))
(check-sat)
(get-value (sx))
(get-value (sy))
(get-value (sz))
