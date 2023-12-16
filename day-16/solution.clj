(ns solution)

(require '[clojure.string :as cs])

(defn next-dirs
  "given row-col-dir triple, figure out the next heading"
  [grid [row col dir]]
  (case (get-in grid [row col])

    \. (list dir)  ;; dot continues on

    ;; pipe forces north-south movement
    \| (case dir
         (:west :east) '(:north :south)
         :north        '(:north)
         :south        '(:south))

    ;; dash forces east-west movement
    \- (case dir
         (:west :east)   (list dir)
         (:north :south) '(:west :east))

    ;; slashes cause reflection
    \\ (case dir :west '(:north) :east '(:south) :north '(:west) :south '(:east))
    \/ (case dir :west '(:south) :east '(:north) :north '(:east) :south '(:west))
  ))

(defn next-coord [[row col :as current] future-dir]
  "translate future-dir to actual coords"
  (case future-dir
    :west  [row (dec col) :west]
    :east  [row (inc col) :east]
    :north [(dec row) col :north]
    :south [(inc row) col :south]
  ))

(defn next-coords [grid [row col dir]]
  "given row-col-dir triple, calculate list of next coords"
  (->> [row col dir]
       (next-dirs grid)
       (map (partial next-coord [row col]))
    ))

(defn in-grid [grid [row col dir]]
  "return row-col-dir triple if row-col is in the grid"
  (if
    (and (< -1 row (count grid))         ;; row in -1 .. num-rows
         (< -1 col (count (grid row))))  ;; col in -1 .. num-cols
    [row col dir]))

(defn fixed-point-iter [f x]
  "fixed-point iterator cf. https://en.wikipedia.org/wiki/Fixed-point_iteration"
  (let [f' (f x)] (if (= f' x) x (recur f f')))
  )

(defn single-step [grid [prev current]]
  [(into prev current)
   (->> current
        (map (partial next-coords grid)) ;; get next coordinates
        (apply concat)                   ;;
        (keep (partial in-grid grid))    ;; filter out anything not in grid coords
        (remove prev))]
  )

(defn flood-fill [grid in]
  "run `single-step` until `single-step` returns a fixed point"
  (fixed-point-iter (partial single-step grid) in))

(defn traverse [grid loc]
  (->> [#{} #{loc}]
       (flood-fill grid)
       (first)
       (map (partial take 2))
       (set)
       (count)))

(defn all-starting-positions [grid]
  "all possible starting positions all around the edges of the grid"
  (let [last-row (dec (count grid))
        all-rows (range (count grid))
        last-col (dec (count (grid 0)))
        all-cols (range (count (grid 0)))]
  (concat
    (map (fn [row] [row      last-col :west])  all-rows)
    (map (fn [row] [row      0        :east])  all-rows)
    (map (fn [col] [last-row 0        :north]) all-cols)
    (map (fn [col] [0        col      :south]) all-cols)
  )))

(let
  [grid (->> (slurp *in*)
             (cs/split-lines)
             (mapv vec)
          )]
  (println "Pt1:"
           (->> [0 0 :east]
                (traverse grid)))
  (println "Pt2:"
           (->> (all-starting-positions grid)
                (map (partial traverse grid))
                (apply max)))
  )
