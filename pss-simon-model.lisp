;;; PSS _ SImon task


;;; main idea, same as Lovett's NJAMOS
;;; Selective attention is competition among productions.

(clear-all)

(define-model pssimon

(sgp :er t
     :act nil
     :esc T
     :ans 0.05
     :auto-attend T
     :le 0.67
     :lf 0.3
     :mas 5.0
     :ul T
     :egs 0.1
     :reward-hook bg-reward-hook
     :alpha 0.01
     :imaginal-activation 1.0
     :visual-activation 2.0)

(chunk-type (simon-stimulus (:include visual-object))
	    kind shape color position)

(chunk-type (simon-screen (:include visual-object))
	    kind value)

(chunk-type (simon-stimulus-location (:include visual-location))
	    shape color position)

(chunk-type simon-rule kind has-motor-response shape hand dimension)

(chunk-type compatible-response has-motor-response hand position)

(chunk-type wm kind value dimension rule)

(add-dm (simon-rule isa chunk)
	(simon-stimulus isa chunk)
	(simon-screen isa chunk)
	(stimulus isa chunk)
	(done isa chunk)
	(pause isa chunk)
	(circle isa chunk)
	(square isa chunk)
	(shape isa chunk)
	(not-shape isa chunk)
	(position isa chunk)
	(not-position isa chunk)
	(yes isa chunk)
	(no isa chunk)
	(proceed isa chunk)
	
	(circle-left isa simon-rule
		     kind simon-rule
		     has-motor-response yes
		     hand left
		     shape circle
		     dimension shape)

	(square-right isa simon-rule
		      kind simon-rule
		      has-motor-response yes
		      hand right
		      shape square
		      dimension shape)

	(compatible-response-right isa compatible-response
				   has-motor-response yes
				   hand right
				   position right)

	(compatible-response-left isa compatible-response
				  has-motor-response yes
				  hand left
				  position left)

	(stimulus1 isa simon-stimulus
		   shape circle
		   position right
		   color black
		   kind simon-stimulus)

	(wm1 isa wm
	     kind proceed)
)

(p find-screen
   ?visual>
     buffer empty
     state free
   ?visual-location>
     buffer empty
     state free
==>
   +visual-location>
     screen-x lowest
)  

(p prepare-wm
   ?imaginal>
     buffer empty
     state free
==>
   +imaginal>
     isa wm
     kind proceed
     dimension shape
)  


(p process-shape
   =visual>
     kind simon-stimulus
     shape =SHAPE 
   =imaginal>
     kind proceed
     ;;value nil 
 ==>
   =visual>    
   =imaginal>
     dimension shape
     kind done
     ;value =SHAPE
)

(p dont-process-shape
   =visual>
     kind simon-stimulus
     shape =SHAPE
     ;;position =POS
   =imaginal>
     kind proceed
     ;;value nil 
 ==>
   =visual>    
   =imaginal>
     kind done
     ;dimension position
     ;;value =POS
     ;value zeta
)


(p process-position
   =visual>
     kind simon-stimulus
     position =POS 
   =imaginal>
     kind proceed
     ;;value nil 
 ==>
   =visual>    
   =imaginal>
     dimension position
     kind done
     ;value =POS
)

(p dont-process-position
   =visual>
     kind simon-stimulus
     position =POS
     shape =SHAPE
   =imaginal>
     kind proceed
     ;;value nil 
 ==>
   =visual>    
   =imaginal>
     kind done
)

(p check
   =imaginal>
     kind done
   - dimension shape
;   - value nil
   ?retrieval>
     buffer empty
     state free
==>
   =imaginal>
     dimension nil
     kind proceed
   !eval! (trigger-reward -1)
)

(p find-response
   =imaginal>
     kind done

   ?retrieval>
     buffer empty
     state free
 ==>
   =imaginal>    
   +retrieval>
     has-motor-response yes
)   

(p respond
   =retrieval>
     has-motor-response yes
     hand =HAND
   =imaginal>
    - dimension nil   
   ?manual>
     preparation free
     processor free
     execution free
==>
  +manual>
     isa punch
     hand =HAND
     finger index
)      



(p done
   =visual>
      kind simon-screen
      value done
==>
   !stop!
)
)

(spp check :u 10 :fixed-utility t)

(spp process-shape :at 0.150)
(spp process-position :at 0.150)


(defun simon-reload (&key (visicon t))
  (reload)
  (install-device (make-instance 'simon-task))
  (init (current-device))
  (proc-display)
  (when visicon
    (print-visicon)))

