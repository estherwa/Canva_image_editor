(module
    (import "js" "mem" (memory $mem 1))

    (export "convertToGrayscale" (func $convertToGrayscale))
    (export "negative" (func $negative))
    (export "decrease_opacity" (func $reduce_opacity) )
    (export "increase_opacity" (func $increase_opacity) )
    (export  "increase_brightness" (func $increase_brightness))
    (export  "decrease_brightness" (func $decrease_brightness))
    (export "red" (func $red))
    (export "green" (func $green))
    (export "blue" (func $blue))
    (export "flip_columns" (func $flip_columns))
    (export "flip_rows" (func $flip_rows))
    (export "blur" (func $blur3x3))


    (func $convertToGrayscale (param $width i32) (param $height i32)
        (local $len i32) (local $i i32) (local $r i32) (local $g i32) (local $b i32)
        (local $gray i32)

        ;;set len = width * height * 4
        local.get $width
        local.get $height
        i32.mul
        i32.const 4
        i32.mul
        local.set $len      ;; stack empty

        ;;set local i = 0
        i32.const 0
        local.set $i        ;; stack empty

        loop
            ;;set r offset or the current index to read r from
            local.get $i
            local.set $r    ;;stack empty

            ;;set g or the current index to read g from
            local.get $i
            i32.const 1
            i32.add
            local.set $g    ;;stack empty

            ;;set b or the current index to read b from
            local.get $i
            i32.const 2
            i32.add
            local.set $b    ;;stack empty

            ;; grayscale conversion(postfix notation)
            ;; r (0.2126) * g (0.7152) * + b (0.0722) * +
            local.get $r
            i32.load8_u
            f32.convert_i32_u   ;; r in stack
            f32.const 0.2126    ;; r, 0.2126 in stack
            f32.mul             ;; (r * 0.2126) in stack

            local.get $g        
            i32.load8_u
            f32.convert_i32_u
            f32.const 0.7152
            f32.mul
            f32.add             ;; (r * 0.2126) + ( g * 0.7152 ) in stack

            local.get $b
            i32.load8_u
            f32.convert_i32_u 
            f32.const 0.0722
            f32.mul
            f32.add             ;; final grayscale value in f32

            ;; convert value to i32
            i32.trunc_f32_u
            local.set $gray     ;; empty stack

            ;; store the value in r, g, b
            local.get $r
            local.get $gray
            i32.store8          ;; empty stack

            local.get $g
            local.get $gray
            i32.store8          ;; empty stack

            local.get $b
            local.get $gray
            i32.store8          ;; empty stack

            ;;increment i
            i32.const 4
            local.get $i
            i32.add
            local.set $i        ;; empty stack

            ;;condition check for next iteration
            local.get $i
            local.get $len
            i32.lt_u
            br_if 0
        end
    )

    (func $negative (param $width i32) (param $height i32)
        ;; locals
        (local $len i32) (local $i i32) (local $temp i32)

        ;; set len = width * height * 4
        local.get $width
        local.get $height
        i32.const 4
        i32.mul
        i32.mul
        local.set $len

        ;; set i = 0
        i32.const 0
        local.set $i

        loop
            ;; get r, calculate its negative, store the negative
            local.get $i

            i32.const 255
            local.get $i
            i32.load8_u
            i32.sub

            i32.store8              ;; stack empty

            ;; get g, calculate its negative, store the negative
            local.get $i
            i32.const 1
            i32.add
            local.set $temp

            local.get $temp

            i32.const 255
            local.get $temp
            i32.load8_u
            i32.sub

            i32.store8              ;; stack empty
        
            ;; get b, calculate its negative, store the negative
            local.get $i
            i32.const 2
            i32.add
            local.set $temp

            local.get $temp

            i32.const 255
            local.get $temp
            i32.load8_u
            i32.sub

            i32.store8      ;; stack empty

            ;; increment i by 4
            local.get $i
            i32.const 4
            i32.add
            local.set $i    ;; stack empty

            ;; exit if i < len is false
            local.get $i
            local.get $len
            i32.lt_u
            br_if 0            
        end
    )

    (func $reduce_opacity (param $width i32) (param $height i32) (param $reduce_by i32)
        ;; local variables
        (local $len i32) (local $alpha i32) (local $temp i32)

        ;;set len = width * height * 4
        local.get $width
        local.get $height
        i32.const 4
        i32.mul
        i32.mul
        local.set $len      ;; stack empty

        ;; set alpha = 3
        i32.const 3
        local.set $alpha    ;; stack empty

        loop
            (block $reduce_alpha_value
                ;; if alpha = 0 then skip to next iteration
                local.get $alpha
                i32.load8_u
                i32.const 0
                i32.eq
                (if
                    (then
                        br $reduce_alpha_value
                    )
                )

                ;; reduce alpha value by reduce_by amount
                local.get $alpha
                i32.load8_u
                local.get $reduce_by
                i32.sub
                local.set $temp     ;; stack empty

                ;; if temp < 0 then set store 0 at alpha index, else store temp at alpha index
                local.get $temp
                i32.const 0
                i32.lt_s
                (if             ;; stack empty
                    (then
                        (i32.store8 (local.get $alpha) (i32.const 0) )      ;; stack empty
                    )
                    (else
                        ( i32.store8 (local.get $alpha) (local.get $temp) )     ;; stack empty
                    )
                )
            )

            ;; increment alpha by 4
            local.get $alpha
            i32.const 4
            i32.add
            local.set $alpha        ;; stack empty      

            ;; exit if alpha < len is false
            local.get $alpha
            local.get $len
            i32.lt_u
            br_if 0
        end
    )

    (func $increase_opacity (param $width i32) (param $height i32) (param $increase_by i32)
        ;; local variables
        (local $len i32) (local $alpha i32) (local $temp i32)

        ;;set len = width * height * 4
        local.get $width
        local.get $height
        i32.const 4
        i32.mul
        i32.mul
        local.set $len      ;; stack empty

        ;; set alpha = 3
        i32.const 3
        local.set $alpha    ;; stack empty

        loop
            (block $increase_alpha_value
                ;; if alpha = 255 then skip to next iteration
                local.get $alpha
                i32.load8_u
                i32.const 255
                i32.eq
                (if
                    (then
                        br $increase_alpha_value
                    )
                )

                ;; increase alpha value by increase_by amount
                local.get $alpha
                i32.load8_u
                local.get $increase_by
                i32.add
                local.set $temp     ;; stack empty

                ;; if temp > 255 then set store 255 at alpha index, else store temp at alpha index
                local.get $temp
                i32.const 255
                i32.gt_s
                (if             ;; stack empty
                    (then
                        (i32.store8 (local.get $alpha) (i32.const 255) )      ;; stack empty
                    )
                    (else
                        ( i32.store8 (local.get $alpha) (local.get $temp) )     ;; stack empty
                    )
                )
            )

            ;; increment alpha by 4
            local.get $alpha
            i32.const 4
            i32.add
            local.set $alpha        ;; stack empty      

            ;; exit if alpha < len is false
            local.get $alpha
            local.get $len
            i32.lt_u
            br_if 0
        end
    )
    
    (func $increase_brightness (param $width i32) (param $height i32) (param $increase_by i32)
        ;; local
        (local $len i32) (local $i i32)

        ;; set len = width * height * 4
        local.get $width
        local.get $height
        i32.const 4
        i32.mul
        i32.mul
        local.set $len                  ;; stack empty

        ;; set i = 0
        i32.const 0
        local.set $i                    ;; stack empty

        loop
            ;; increase brightness by adding the increase_by constant to red, green and blue channel
            (block $main
                ;; if red = 255, then skip whole pixel
                    local.get $i
                    i32.load8_u
                    
                    i32.const 256
                    local.get $increase_by
                    i32.sub

                    i32.ge_u
                    (if ( then br $main ) )

                ;; if green = 255, then skip whole pixel
                    local.get $i
                    i32.const 1
                    i32.add
                    i32.load8_u
                    
                    i32.const 256
                    local.get $increase_by
                    i32.sub

                    i32.ge_u
                    (if ( then br $main ) )

                ;; if blue = 255, then skip whole pixel
                    local.get $i
                    i32.const 2
                    i32.add
                    i32.load8_u
                    
                    i32.const 256
                    local.get $increase_by
                    i32.sub

                    i32.ge_u
                    (if ( then br $main ) )

                ;; RED
                    local.get $i

                    local.get $i
                    i32.load8_u
                    local.get $increase_by
                    i32.add

                    i32.store8

                ;; GREEN
                    local.get $i
                    i32.const 1
                    i32.add
                    
                    local.get $i
                    i32.const 1
                    i32.add
                    i32.load8_u
                    local.get $increase_by
                    i32.add

                    i32.store8

                ;; BLUE
                    local.get $i
                    i32.const 2
                    i32.add
                    
                    local.get $i
                    i32.const 2
                    i32.add
                    i32.load8_u
                    local.get $increase_by
                    i32.add

                    i32.store8
            )

            ;; increment i by 4
            local.get $i
            i32.const 4
            i32.add
            local.set $i                ;; stack empty

            ;; exit if i < len is false
            local.get $i
            local.get $len
            i32.lt_s
            br_if 0
        end

    )
    (func $decrease_brightness (param $width i32) (param $height i32) (param $decrease_by i32)
        ;; local
        (local $len i32) (local $i i32)

        ;; set len = width * height * 4
        local.get $width
        local.get $height
        i32.const 4
        i32.mul
        i32.mul
        local.set $len                  ;; stack empty

        ;; set i = 0
        i32.const 0
        local.set $i                    ;; stack empty

        loop
            ;; decrease brightness by subtracting the decrease_by constant to red, green and blue channel
            (block $main
                ;; if red = 0, then skip whole pixel
                    local.get $i
                    i32.load8_u
                    
                    local.get $decrease_by
                    i32.sub

                    i32.const 0
                    i32.lt_s
                    (if ( then br $main ) )

                ;; if green = 0, then skip whole pixel
                    local.get $i
                    i32.const 1
                    i32.add
                    i32.load8_u
                    
                    local.get $decrease_by
                    i32.sub

                    i32.const 0
                    i32.lt_s
                    (if ( then br $main ) )

                ;; if blue = 0, then skip whole pixel
                    local.get $i
                    i32.const 2
                    i32.add
                    i32.load8_u
                    
                    local.get $decrease_by
                    i32.sub

                    i32.const 0
                    i32.lt_s
                    (if ( then br $main ) )

                ;; RED
                    local.get $i

                    local.get $i
                    i32.load8_u
                    local.get $decrease_by
                    i32.sub

                    i32.store8

                ;; GREEN
                    local.get $i
                    i32.const 1
                    i32.add
                    
                    local.get $i
                    i32.const 1
                    i32.add
                    i32.load8_u
                    local.get $decrease_by
                    i32.sub

                    i32.store8

                ;; BLUE
                    local.get $i
                    i32.const 2
                    i32.add
                    
                    local.get $i
                    i32.const 2
                    i32.add
                    i32.load8_u
                    local.get $decrease_by
                    i32.sub

                    i32.store8
            )

            ;; increment i by 4
            local.get $i
            i32.const 4
            i32.add
            local.set $i                ;; stack empty

            ;; exit if i < len is false
            local.get $i
            local.get $len
            i32.lt_s
            br_if 0
        end
    )

    (func $red  
        (param $width i32) (param $height i32)
        (local $len i32) (local $i i32 )

        ;; set len = width * height * 4
        local.get $width
        local.get $height
        i32.const 4
        i32.mul
        i32.mul
        local.set $len          ;; stack empty

        ;; set i = 0
        i32.const 0
        local.set $i            ;; stack empty

        loop
            ;; to keep only red, remove green and blue
            ;; green
            local.get $i
            i32.const 1
            i32.add
            i32.const 0
            i32.store8

            ;; blue
            local.get $i
            i32.const 2
            i32.add
            i32.const 0
            i32.store8

            ;; increment i by 4
            local.get $i
            i32.const 4
            i32.add
            local.set $i            ;; stack empty

            ;; exit if i < len is false
            local.get $i
            local.get $len
            i32.lt_u
            br_if 0
        end
    )
    (func $green  
        (param $width i32) (param $height i32)
        (local $len i32) (local $i i32 )

        ;; set len = width * height * 4
        local.get $width
        local.get $height
        i32.const 4
        i32.mul
        i32.mul
        local.set $len          ;; stack empty

        ;; set i = 0
        i32.const 0
        local.set $i            ;; stack empty

        loop
            ;; to keep only green, remove red and blue
            ;; red
            local.get $i
            i32.const 0
            i32.store8

            ;; blue
            local.get $i
            i32.const 2
            i32.add
            i32.const 0
            i32.store8

            ;; increment i by 4
            local.get $i
            i32.const 4
            i32.add
            local.set $i            ;; stack empty

            ;; exit if i < len is false
            local.get $i
            local.get $len
            i32.lt_u
            br_if 0
        end
    )
    (func $blue  
        (param $width i32) (param $height i32)
        (local $len i32) (local $i i32 )

        ;; set len = width * height * 4
        local.get $width
        local.get $height
        i32.const 4
        i32.mul
        i32.mul
        local.set $len          ;; stack empty

        ;; set i = 0
        i32.const 0
        local.set $i            ;; stack empty

        loop
            ;; to keep only blue, remove red and green
            ;; red
            local.get $i
            i32.const 0
            i32.store8

            ;; green
            local.get $i
            i32.const 1
            i32.add
            i32.const 0
            i32.store8

            ;; increment i by 4
            local.get $i
            i32.const 4
            i32.add
            local.set $i            ;; stack empty

            ;; exit if i < len is false
            local.get $i
            local.get $len
            i32.lt_u
            br_if 0
        end
    )

    (func $flip_columns (param $width i32) (param $height i32)
        ;; local variables
        (local $left i32) (local $right i32)
        (local $width_minus_1 i32) (local $width_mul_4 i32) (local $temp i32)
        (local $row i32) (local $left_px_index i32) (local $right_px_index i32)

        ;; set width_minus_1 = (width * 4) - 4
        local.get $width
        i32.const 4
        i32.mul
        i32.const 4
        i32.sub
        local.set $width_minus_1    ;; stack empty

        ;; set width_mul_4 = width * 4
        local.get $width
        i32.const 4
        i32.mul
        local.set $width_mul_4      ;; stack empty

        ;; set row = 0
        i32.const 0
        local.set $row              ;; stack empty

        loop
            ;; set left = 0
            i32.const 0
            local.set $left     ;; stack empty

            ;; set right = width - 1
            local.get $width_minus_1
            local.set $right    ;; stack empty

            loop
                ;; find left_px_index using ( current_row * (width * 4) + left )
                local.get $row
                local.get $width_mul_4
                i32.mul
                local.get $left
                i32.add
                local.set $left_px_index    ;; stack empty

                ;; find right_px_index using ( current_row * (width * 4) + right )
                local.get $row
                local.get $width_mul_4
                i32.mul
                local.get $right
                i32.add
                local.set $right_px_index    ;; stack empty

                ;;===========================================================
                ;; swap left and right

                ;; swap red
                    local.get $left_px_index
                    i32.load8_u
                    local.set $temp     ;; stack empty

                    local.get $left_px_index
                    local.get $right_px_index
                    i32.load8_u
                    i32.store8          ;; stack empty

                    local.get $right_px_index
                    local.get $temp
                    i32.store8          ;; stack empty

                ;; swap green
                    local.get $left_px_index
                    i32.const 1
                    i32.add
                    i32.load8_u
                    local.set $temp     ;; stack empty
                    
                    local.get $left_px_index
                    i32.const 1
                    i32.add
                    local.get $right_px_index
                    i32.const 1
                    i32.add
                    i32.load8_u
                    i32.store8          ;; stack empty

                    local.get $right_px_index
                    i32.const 1
                    i32.add
                    local.get $temp
                    i32.store8          ;; stack empty
                
                ;; swap blue
                    local.get $left_px_index
                    i32.const 2
                    i32.add
                    i32.load8_u
                    local.set $temp     ;; stack empty
                    
                    local.get $left_px_index
                    i32.const 2
                    i32.add
                    local.get $right_px_index
                    i32.const 2
                    i32.add
                    i32.load8_u
                    i32.store8          ;; stack empty

                    local.get $right_px_index
                    i32.const 2
                    i32.add
                    local.get $temp
                    i32.store8          ;; stack empty

                ;; swap alpha
                    local.get $left_px_index
                    i32.const 3
                    i32.add
                    i32.load8_u
                    local.set $temp     ;; stack empty
                    
                    local.get $left_px_index
                    i32.const 3
                    i32.add
                    local.get $right_px_index
                    i32.const 3
                    i32.add
                    i32.load8_u
                    i32.store8          ;; stack empty

                    local.get $right_px_index
                    i32.const 3
                    i32.add
                    local.get $temp
                    i32.store8          ;; stack empty
                
                ;;===========================================================
                
                ;; increment left by 4
                local.get $left
                i32.const 4
                i32.add
                local.set $left             ;; stack empty

                ;; decrement right by 4
                local.get $right
                i32.const 4
                i32.sub
                local.set $right            ;; stack empty    

                ;; exit code, left < right
                local.get $left
                local.get $right
                i32.lt_u
                br_if 0
            end

            ;; increment row
            i32.const 1
            local.get $row
            i32.add
            local.set $row       ;; empty stack

            ;; exit code, check if all rows are processed
            local.get $row
            i32.const 1
            i32.sub
            local.get $height
            i32.lt_u
            br_if 0
        end
    )
    (func $flip_rows (param $width i32) (param $height i32)
        ;;local variables
        (local $width_mul_4 i32) (local $height_minus_1 i32)
        (local $top i32) (local $bottom i32) (local $col i32)
        (local $top_px_index i32) (local $bottom_px_index i32)

        ;; set width_mul_4 = width * 4
        local.get $width
        i32.const 4
        i32.mul
        local.set $width_mul_4      ;; stack empty

        ;; set height_minus_1 = height - 1
        local.get $height
        i32.const 1
        i32.sub
        local.set $height_minus_1   ;; stack empty

        ;;set col = 0
        i32.const 0
        local.set $col              ;; stack empty

        loop
            ;; set top = 0
            i32.const 0
            local.set $top          ;; stack empty

            ;; set bottom = height - 1
            local.get $height_minus_1
            local.set $bottom           ;; stack empty

            loop
                ;; find top_px_index by - (top * (width * 4)) + col
                local.get $top
                local.get $width_mul_4
                i32.mul
                local.get $col
                i32.add
                local.set $top_px_index     ;; stack empty

                ;; find bottom_px_index by - (bottom * (width * 4)) + col
                local.get $bottom
                local.get $width_mul_4
                i32.mul
                local.get $col
                i32.add
                local.set $bottom_px_index     ;; stack empty

                ;;====================================================================
                ;; swap top and bottom pixels
                local.get $top_px_index
                local.get $bottom_px_index
                call $swap_pixels
                ;;====================================================================

                ;; increment top by 1, top += 1
                local.get $top
                i32.const 1
                i32.add
                local.set $top      ;; stack empty

                ;; decrement bottom by 1, bottom -= 1
                local.get $bottom
                i32.const 1
                i32.sub
                local.set $bottom   ;; stack empty

                ;; exit if top < bottom is false
                local.get $top
                local.get $bottom
                i32.lt_u
                br_if 0
            end

            ;; increment col by 4, col += 4
            local.get $col
            i32.const 4
            i32.add
            local.set $col          ;; stack empty

            ;; exit if col < (width * 4) is false
            local.get $col
            local.get $width_mul_4
            i32.lt_u
            br_if 0
        end
    )
    (func $swap_pixels (param $px1_index i32) (param $px2_index i32) (local $temp i32)
        ;; swap red
            ;; temp = px1
            local.get $px1_index
            i32.load8_u
            local.set $temp         ;; stack empty

            ;; px1 = px2
            local.get $px1_index
            local.get $px2_index
            i32.load8_u
            i32.store8              ;; stack empty

            ;; px2 = temp
            local.get $px2_index
            local.get $temp
            i32.store8              ;; stack empty

        ;; swap green
            ;; temp = px1
            local.get $px1_index
            i32.const 1
            i32.add
            i32.load8_u
            local.set $temp         ;; stack empty

            ;; px1 = px2
            local.get $px1_index
            i32.const 1
            i32.add
            local.get $px2_index
            i32.const 1
            i32.add
            i32.load8_u
            i32.store8              ;; stack empty

            ;; px2 = temp
            local.get $px2_index
            i32.const 1
            i32.add
            local.get $temp
            i32.store8             ;; stack empty

        ;; swap blue
            ;; temp = px1
            local.get $px1_index
            i32.const 2
            i32.add
            i32.load8_u
            local.set $temp         ;; stack empty

            ;; px1 = px2
            local.get $px1_index
            i32.const 2
            i32.add
            local.get $px2_index
            i32.const 2
            i32.add
            i32.load8_u
            i32.store8              ;; stack empty

            ;; px2 = temp
            local.get $px2_index
            i32.const 2
            i32.add
            local.get $temp
            i32.store8            ;; stack empty

        ;; swap alpha
        ;; temp = px1
        local.get $px1_index
        i32.const 3
        i32.add
        i32.load8_u
        local.set $temp         ;; stack empty

        ;; px1 = px2
        local.get $px1_index
        i32.const 3
        i32.add
        local.get $px2_index
        i32.const 3
        i32.add
        i32.load8_u
        i32.store8              ;; stack empty

        ;; px2 = temp
        local.get $px2_index
        i32.const 3
        i32.add
        local.get $temp
        i32.store8             ;; stack empty
    )



    (func $blur3x3 (param $width i32) (param $height i32) 
        ;; locals
        (local $row i32) (local $col i32) (local $lr_index i32) (local $len i32)
        (local $width_minus_1 i32) (local $height_minus_1 i32)
        (local $width_minus_1_mul_4 i32) 
        (local $width4 i32)

        ;; set width4 = width * 4
        local.get $width
        i32.const 4
        i32.mul
        local.set $width4

        ;; set len = width * len * 4
        local.get $width
        local.get $height
        i32.const 4
        i32.mul
        i32.mul
        local.set $len                                  ;; stack empty

        ;; set width_minus_1 = ( width - 1 )
        local.get $width
        i32.const 1
        i32.sub
        local.set $width_minus_1                        ;; stack empty
        
        ;; set height_minus_1 = ( height - 1 )
        local.get $height
        i32.const 1
        i32.sub
        local.set $height_minus_1                        ;; stack empty
        
        ;; set width_minus_1_mul_4 = ( width - 1 ) * 4
        local.get $width_minus_1
        i32.const 4
        i32.mul
        local.set $width_minus_1_mul_4                        ;; stack empty

        ;; set row = 1 
        i32.const 1
        local.set $row                                  ;; stack empty

        loop
            ;; set col = 1
            i32.const 1
            local.set $col                              ;; stack empty

            loop
                ;;========================================================================
                ;; CONVOLUTION LOGIC
                ;;========================================================================
                local.get $row
                local.get $col
                local.get $width
                call $get_linear_index
                local.set $lr_index

                ;; RED
                    local.get $lr_index
                    local.get $len
                    i32.add                    ;; offset for storing new values

                    local.get $lr_index
                    call $process_center_pixel                  ;; returns f32

                    local.get $lr_index
                    local.get $width
                    call $process_topbottomleftright_pixels     ;; returns f32

                    local.get $lr_index
                    local.get $width
                    call $process_corner_pixels                 ;; returns f32
                    
                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8
                
                ;; GREEN
                    ;; increment lr_index by i
                    local.get $lr_index
                    i32.const 1
                    i32.add
                    local.set $lr_index

                    ;; process the green pixel
                    local.get $lr_index
                    local.get $len
                    i32.add                    ;; offset for storing new values

                    local.get $lr_index
                    call $process_center_pixel                  ;; returns f32

                    local.get $lr_index
                    local.get $width
                    call $process_topbottomleftright_pixels     ;; returns f32

                    local.get $lr_index
                    local.get $width
                    call $process_corner_pixels                 ;; returns f32
                    
                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8

                ;; BLUE
                    ;; increment lr_index by i
                    local.get $lr_index
                    i32.const 1
                    i32.add
                    local.set $lr_index

                    ;; process the blue pixel
                    local.get $lr_index
                    local.get $len
                    i32.add                    ;; offset for storing new values

                    local.get $lr_index
                    call $process_center_pixel                  ;; returns f32

                    local.get $lr_index
                    local.get $width
                    call $process_topbottomleftright_pixels     ;; returns f32

                    local.get $lr_index
                    local.get $width
                    call $process_corner_pixels                 ;; returns f32
                    
                    ;; find weighted average = (center + corners + topleftbottomright) 
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8

                ;; ALPHA
                    ;; increment lr_index by i
                    local.get $lr_index
                    i32.const 1
                    i32.add
                    local.set $lr_index

                    ;; process the alpha pixel
                    local.get $lr_index
                    local.get $len
                    i32.add                    ;; offset for storing new values

                    local.get $lr_index
                    i32.load8_u

                    i32.store8
                ;;========================================================================
                ;;========================================================================

                ;; increment col by 1
                local.get $col
                i32.const 1
                i32.add
                local.set $col                          ;; stack empty

                ;; exit if col < ( width - 1 ) is false
                local.get $col
                local.get $width_minus_1
                i32.lt_s
                br_if 0
            end

            ;; increment row by 1
            local.get $row
            i32.const 1
            i32.add
            local.set $row                              ;; stack empty

            ;; exit if row < ( height - 1) is false
            local.get $row
            local.get $height_minus_1
            i32.lt_s
            br_if 0
        end

        ;; HANDLE EDGES
        ;; top row
            ;; set row = 4, row acts as incrementor( like 'i' ) here
            i32.const 4
            local.set $row
            loop
                ;; RED
                    local.get $row
                    local.get $len
                    i32.add
                    ;; center
                    local.get $row
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; left
                    local.get $row
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; right
                    local.get $row
                    i32.const 4
                    i32.add
                    i32.load8_u
                    ;; bottom
                    ;; top , doesn't exist hence bottom pixel will be taken
                    local.get $row
                    local.get $width4
                    i32.add
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( bottom-left + bottom-right )
                    ;; bottom-left
                    local.get $row
                    local.get $width4
                    i32.add
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; bottom-right
                    local.get $row
                    local.get $width4
                    i32.const 4
                    i32.add
                    i32.add
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8
                
                ;; GREEN
                    local.get $row
                    i32.const 1
                    i32.add
                    local.get $len
                    i32.add
                    ;; center
                    local.get $row
                    i32.const 1
                    i32.add
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; left
                    local.get $row
                    i32.const 1
                    i32.add

                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; right
                    local.get $row
                    i32.const 1
                    i32.add

                    i32.const 4
                    i32.add
                    i32.load8_u
                    ;; bottom
                    ;; top , doesn't exist hence bottom pixel will be taken
                    local.get $row
                    i32.const 1
                    i32.add

                    local.get $width4
                    i32.add
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( bottom-left + bottom-right )
                    ;; bottom-left
                    local.get $row
                    i32.const 1
                    i32.add

                    local.get $width4
                    i32.add
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; bottom-right
                    local.get $row
                    i32.const 1
                    i32.add
                    
                    local.get $width4
                    i32.const 4
                    i32.add
                    i32.add
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8

                ;; BLUE
                    local.get $row
                    i32.const 2
                    i32.add
                    local.get $len
                    i32.add
                    ;; center
                    local.get $row
                    i32.const 2
                    i32.add
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; left
                    local.get $row
                    i32.const 2
                    i32.add

                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; right
                    local.get $row
                    i32.const 2
                    i32.add

                    i32.const 4
                    i32.add
                    i32.load8_u
                    ;; bottom
                    ;; top , doesn't exist hence bottom pixel will be taken
                    local.get $row
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.add
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( bottom-left + bottom-right )
                    ;; bottom-left
                    local.get $row
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.add
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; bottom-right
                    local.get $row
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.const 4
                    i32.add
                    i32.add
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8

                ;; increment row by 4
                local.get $row
                i32.const 4
                i32.add
                local.set $row                      ;; stack empty

                ;; exit if row < ( width - 1 ) * 4
                local.get $row
                local.get $width_minus_1_mul_4
                i32.lt_u
                br_if 0
            end

        ;; bottom row
            ;; set row = 2nd pixel of last row, row acts as incrementor( like 'i' ) here
            local.get $height_minus_1
            i32.const 1
            local.get $width
            call $get_linear_index
            local.set $row
            loop
                ;; RED
                    local.get $row
                    local.get $len
                    i32.add                 ;; offset for storing new values
                    ;; center
                    local.get $row
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; left
                    local.get $row
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; right
                    local.get $row
                    i32.const 4
                    i32.add
                    i32.load8_u
                    ;; top
                    ;; bottom doesn't exist hence top pixel will be taken
                    local.get $row
                    local.get $width4
                    i32.sub
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( bottom-left + bottom-right )
                    ;; top-left
                    local.get $row
                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; top-right
                    local.get $row
                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.add
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8
                
                ;; GREEN
                    local.get $row
                    i32.const 1
                    i32.add
                    local.get $len
                    i32.add                           ;; offset for storing new values
                    ;; center
                    local.get $row
                    i32.const 1
                    i32.add
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; left
                    local.get $row
                    i32.const 1
                    i32.add

                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; right
                    local.get $row
                    i32.const 1
                    i32.add

                    i32.const 4
                    i32.add
                    i32.load8_u
                    ;; top
                    ;; bottom doesn't exist hence top pixel will be taken
                    local.get $row
                    i32.const 1
                    i32.add

                    local.get $width4
                    i32.sub
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( top-left + top-right )
                    ;; top-left
                    local.get $row
                    i32.const 1
                    i32.add

                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; top-right
                    local.get $row
                    i32.const 1
                    i32.add
                    
                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.add
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8

                ;; BLUE
                    local.get $row
                    i32.const 2
                    i32.add
                    local.get $len
                    i32.add                                 ;; offset for storing new values
                    ;; center
                    local.get $row
                    i32.const 2
                    i32.add
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; left
                    local.get $row
                    i32.const 2
                    i32.add

                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; right
                    local.get $row
                    i32.const 2
                    i32.add

                    i32.const 4
                    i32.add
                    i32.load8_u
                    ;; top
                    ;; bottom doesn't exist hence top pixel will be taken
                    local.get $row
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.sub
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( top-left + top-right )
                    ;; top-left
                    local.get $row
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; top-right
                    local.get $row
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.add
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8

                ;; increment row by 4
                local.get $row
                i32.const 4
                i32.add
                local.set $row                      ;; stack empty

                ;; exit if row < len - 4
                local.get $row
                local.get $len
                i32.const 4
                i32.sub
                i32.lt_u
                br_if 0
            end

        ;; left col
            ;; set col to index of (1, 0), col acts as incrementor
            i32.const 1
            i32.const 0
            local.get $width
            call $get_linear_index
            local.set $col
            loop
                ;; RED
                    local.get $col
                    local.get $len
                    i32.add                 ;; offset for storing new values
                    ;; center
                    local.get $col
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; top
                    local.get $col
                    local.get $width4
                    i32.sub
                    i32.load8_u
                    ;; bottom
                    local.get $col
                    local.get $width4
                    i32.add
                    i32.load8_u
                    ;; right
                    ;; left doesn't exist hence twice of right will be taken
                    local.get $col
                    i32.const 4
                    i32.add
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( top-right + bottom-right )
                    ;; top-right
                    local.get $col
                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.add
                    i32.load8_u
                    ;; bottom-right
                    local.get $col
                    local.get $width4
                    i32.add
                    i32.const 4
                    i32.add
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8
                
                ;; GREEN
                    local.get $col
                    i32.const 1
                    i32.add
                    local.get $len
                    i32.add                           ;; offset for storing new values

                    ;; center
                    local.get $col
                    i32.const 1
                    i32.add
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; top
                    local.get $col
                    i32.const 1
                    i32.add
                    
                    local.get $width4
                    i32.sub
                    i32.load8_u
                    ;; bottom
                    local.get $col
                    i32.const 1
                    i32.add

                    local.get $width4
                    i32.add
                    i32.load8_u
                    ;; right
                    ;; left doesn't exist hence twice of right will be taken
                    local.get $col
                    i32.const 1
                    i32.add

                    i32.const 4
                    i32.add
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( top-right + bottom-right )
                    ;; top-right
                    local.get $col
                    i32.const 1
                    i32.add

                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.add
                    i32.load8_u
                    ;; bottom-right
                    local.get $col
                    i32.const 1
                    i32.add
                    
                    local.get $width4
                    i32.add
                    i32.const 4
                    i32.add
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8
                
                ;; BLUE
                    local.get $col
                    i32.const 2
                    i32.add
                    local.get $len
                    i32.add                           ;; offset for storing new values

                    ;; center
                    local.get $col
                    i32.const 2
                    i32.add
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; top
                    local.get $col
                    i32.const 2
                    i32.add
                    
                    local.get $width4
                    i32.sub
                    i32.load8_u
                    ;; bottom
                    local.get $col
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.add
                    i32.load8_u
                    ;; right
                    ;; left doesn't exist hence twice of right will be taken
                    local.get $col
                    i32.const 2
                    i32.add

                    i32.const 4
                    i32.add
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( top-right + bottom-right )
                    ;; top-right
                    local.get $col
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.add
                    i32.load8_u
                    ;; bottom-right
                    local.get $col
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.add
                    i32.const 4
                    i32.add
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8

                ;; increment col by one row
                local.get $col
                local.get $width4
                i32.add
                local.set $col

                ;; exit if [ col < ( height - 1) * width * 4 ] is false
                local.get $col
                local.get $height_minus_1
                local.get $width4
                i32.mul
                i32.lt_s
                br_if 0
            end

        ;; right col
            ;; set col to index of (1, ( width - 1 ) * 4 ), col acts as incrementor
            i32.const 1
            local.get $width_minus_1
            local.get $width
            call $get_linear_index
            local.set $col
            loop
                ;; RED
                    local.get $col
                    local.get $len
                    i32.add                 ;; offset for storing new values
                    ;; center
                    local.get $col
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; top
                    local.get $col
                    local.get $width4
                    i32.sub
                    i32.load8_u
                    ;; bottom
                    local.get $col
                    local.get $width4
                    i32.add
                    i32.load8_u
                    ;; left
                    ;; right doesn't exist hence twice of left will be taken
                    local.get $col
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( top-left + bottom-left )
                    ;; top-left
                    local.get $col
                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; bottom-left
                    local.get $col
                    local.get $width4
                    i32.add
                    i32.const 4
                    i32.sub
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8
                
                ;; GREEN
                    local.get $col
                    i32.const 1
                    i32.add
                    local.get $len
                    i32.add                           ;; offset for storing new values

                    ;; center
                    local.get $col
                    i32.const 1
                    i32.add
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; top
                    local.get $col
                    i32.const 1
                    i32.add
                    
                    local.get $width4
                    i32.sub
                    i32.load8_u
                    ;; bottom
                    local.get $col
                    i32.const 1
                    i32.add

                    local.get $width4
                    i32.add
                    i32.load8_u
                    ;; left
                    ;; right doesn't exist hence twice of left will be taken
                    local.get $col
                    i32.const 1
                    i32.add

                    i32.const 4
                    i32.sub
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( top-left + bottom-left )
                    ;; top-left
                    local.get $col
                    i32.const 1
                    i32.add

                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; bottom-left
                    local.get $col
                    i32.const 1
                    i32.add
                    
                    local.get $width4
                    i32.add
                    i32.const 4
                    i32.sub
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8
                
                ;; BLUE
                    local.get $col
                    i32.const 2
                    i32.add
                    local.get $len
                    i32.add                           ;; offset for storing new values

                    ;; center
                    local.get $col
                    i32.const 2
                    i32.add
                    i32.load8_u
                    f32.convert_i32_u
                    f32.const 0.272496
                    f32.mul

                    ;; top
                    local.get $col
                    i32.const 2
                    i32.add
                    
                    local.get $width4
                    i32.sub
                    i32.load8_u
                    ;; bottom
                    local.get $col
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.add
                    i32.load8_u
                    ;; left
                    ;; right doesn't exist hence twice of left will be taken
                    local.get $col
                    i32.const 2
                    i32.add

                    i32.const 4
                    i32.sub
                    i32.load8_u
                    i32.const 2
                    i32.mul
                    ;; add left + right + top + bottom
                    i32.add
                    i32.add
                    f32.convert_i32_u
                    f32.const 0.124758
                    f32.mul

                    ;; corners, 2 ( top-left + bottom-left )
                    ;; top-left
                    local.get $col
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.sub
                    i32.const 4
                    i32.sub
                    i32.load8_u
                    ;; bottom-left
                    local.get $col
                    i32.const 2
                    i32.add

                    local.get $width4
                    i32.add
                    i32.const 4
                    i32.sub
                    i32.load8_u

                    i32.add
                    i32.const 2
                    i32.mul
                    f32.convert_i32_u
                    f32.const 0.057118
                    f32.mul

                    ;; find weighted average = (center + corners + topleftbottomright)
                    f32.add
                    f32.add

                    ;; convert back to i32 and store
                    i32.trunc_f32_s
                    i32.store8

                ;; increment col by one row
                local.get $col
                local.get $width4
                i32.add
                local.set $col

                ;; exit if ( col < ( len - width*4 ) ) is false
                local.get $col
                local.get $len
                local.get $width4
                i32.sub
                i32.lt_s
                br_if 0
            end

        ;; top left pixel
            ;; RED
                local.get $len
                ;; center
                i32.const 0
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; bottom
                ;; top doesn't exist hence twice of bottom will be taken
                i32.const 0
                local.get $width4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; right
                ;; left doesn't exist hence twice of right will be taken
                i32.const 0
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * bottom-right
                i32.const 0
                local.get $width4
                i32.add
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
            ;; GREEN
                local.get $len
                i32.const 1
                i32.add
                ;; center
                i32.const 1
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; bottom
                ;; top doesn't exist hence twice of bottom will be taken
                i32.const 1
                local.get $width4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; right
                ;; left doesn't exist hence twice of right will be taken
                i32.const 1
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * bottom-right
                i32.const 1
                local.get $width4
                i32.add
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
            ;; BLUE
                local.get $len
                i32.const 2
                i32.add
                ;; center
                i32.const 2
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; bottom
                ;; top doesn't exist hence twice of bottom will be taken
                i32.const 2
                local.get $width4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; right
                ;; left doesn't exist hence twice of right will be taken
                i32.const 2
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * bottom-right
                i32.const 2
                local.get $width4
                i32.add
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
        ;; top right pixel
            ;; RED
                local.get $width_minus_1_mul_4
                local.get $len
                i32.add
                ;; center
                local.get $width_minus_1_mul_4
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; bottom
                ;; top doesn't exist hence twice of bottom will be taken
                local.get $width_minus_1_mul_4
                local.get $width4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; left
                ;; right doesn't exist hence twice of left will be taken
                local.get $width_minus_1_mul_4
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * bottom-left
                local.get $width_minus_1_mul_4
                local.get $width4
                i32.add
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
            ;; GREEN
                local.get $width_minus_1_mul_4
                i32.const 1
                i32.add
                local.get $len
                i32.add
                ;; center
                local.get $width_minus_1_mul_4
                i32.const 1
                i32.add
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; bottom
                ;; top doesn't exist hence twice of bottom will be taken
                local.get $width_minus_1_mul_4
                i32.const 1
                i32.add
                local.get $width4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; left
                ;; right doesn't exist hence twice of left will be taken
                local.get $width_minus_1_mul_4
                i32.const 1
                i32.add
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * bottom-left
                local.get $width_minus_1_mul_4
                i32.const 1
                i32.add
                local.get $width4
                i32.add
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
            ;; BLUE
                local.get $width_minus_1_mul_4
                i32.const 2
                i32.add
                local.get $len
                i32.add
                ;; center
                local.get $width_minus_1_mul_4
                i32.const 2
                i32.add
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; bottom
                ;; top doesn't exist hence twice of bottom will be taken
                local.get $width_minus_1_mul_4
                i32.const 2
                i32.add
                local.get $width4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; left
                ;; right doesn't exist hence twice of left will be taken
                local.get $width_minus_1_mul_4
                i32.const 2
                i32.add
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * bottom-left
                local.get $width_minus_1_mul_4
                i32.const 2
                i32.add
                local.get $width4
                i32.add
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8

        
        ;; bottom left pixel
            local.get $height_minus_1
            i32.const 0
            local.get $width
            call $get_linear_index
            local.set $row          ;; row acts as temporary variable here
            ;; RED
                local.get $row
                local.get $len
                i32.add
                ;; center
                local.get $row
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; top
                ;; bottom doesn't exist hence twice of top will be taken
                local.get $row
                local.get $width4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; right
                ;; left doesn't exist hence twice of right will be taken
                local.get $row
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * top-right
                local.get $row
                local.get $width4
                i32.sub
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
            ;; GREEN
                local.get $row
                i32.const 1
                i32.add
                local.get $len
                i32.add
                ;; center
                local.get $row
                i32.const 1
                i32.add

                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; top
                ;; bottom doesn't exist hence twice of top will be taken
                local.get $row
                i32.const 1
                i32.add

                local.get $width4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; right
                ;; left doesn't exist hence twice of right will be taken
                local.get $row
                i32.const 1
                i32.add

                i32.const 4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * top-right
                local.get $row
                i32.const 1
                i32.add

                local.get $width4
                i32.sub
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
            ;; BLUE
                local.get $row
                i32.const 2
                i32.add
                local.get $len
                i32.add
                ;; center
                local.get $row
                i32.const 2
                i32.add

                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; top
                ;; bottom doesn't exist hence twice of top will be taken
                local.get $row
                i32.const 2
                i32.add

                local.get $width4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; right
                ;; left doesn't exist hence twice of right will be taken
                local.get $row
                i32.const 2
                i32.add

                i32.const 4
                i32.add
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * top-right
                local.get $row
                i32.const 2
                i32.add

                local.get $width4
                i32.sub
                i32.const 4
                i32.add
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
        ;; bottom right pixel
            local.get $len
            i32.const 4
            i32.sub
            local.set $row          ;; row acts as temporary variable here
            ;; RED
                local.get $row
                local.get $len
                i32.add
                ;; center
                local.get $row
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; top
                ;; bottom doesn't exist hence twice of top will be taken
                local.get $row
                local.get $width4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; left
                ;; right doesn't exist hence twice of left will be taken
                local.get $row
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * top-left
                local.get $row
                local.get $width4
                i32.sub
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
            ;; GREEN
                local.get $row
                i32.const 1
                i32.add
                local.get $len
                i32.add
                ;; center
                local.get $row
                i32.const 1
                i32.add
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; top
                ;; bottom doesn't exist hence twice of top will be taken
                local.get $row
                i32.const 1
                i32.add

                local.get $width4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; left
                ;; right doesn't exist hence twice of left will be taken
                local.get $row
                i32.const 1
                i32.add

                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * top-left
                local.get $row
                i32.const 1
                i32.add

                local.get $width4
                i32.sub
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
            ;; BLUE
                local.get $row
                i32.const 2
                i32.add
                local.get $len
                i32.add
                ;; center
                local.get $row
                i32.const 2
                i32.add
                i32.load8_u
                f32.convert_i32_u
                f32.const 0.272496
                f32.mul

                ;; top
                ;; bottom doesn't exist hence twice of top will be taken
                local.get $row
                i32.const 2
                i32.add

                local.get $width4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; left
                ;; right doesn't exist hence twice of left will be taken
                local.get $row
                i32.const 2
                i32.add

                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 2
                i32.mul
                ;; add left + right + top + bottom
                i32.add
                f32.convert_i32_u
                f32.const 0.124758
                f32.mul

                ;; corners, 4 * top-left
                local.get $row
                i32.const 2
                i32.add

                local.get $width4
                i32.sub
                i32.const 4
                i32.sub
                i32.load8_u
                i32.const 4
                i32.mul
                f32.convert_i32_u
                f32.const 0.057118
                f32.mul

                ;; find weighted average = (center + corners + topleftbottomright)
                f32.add
                f32.add

                ;; convert back to i32 and store
                i32.trunc_f32_s
                i32.store8
)

    ;; Utility functions
    (func $get_linear_index (param $row i32) (param $col i32) (param $width i32) (result i32)
        ;; linear_index = ( row * ( width * 4) ) + ( col * 4 )
        local.get $row
        local.get $width
        i32.const 4
        i32.mul
        i32.mul

        local.get $col
        i32.const 4
        i32.mul

        i32.add
        return    
    )

    (func $process_center_pixel (param $index i32) (result f32)
        local.get $index
        i32.load8_u
        f32.convert_i32_u
        f32.const 0.272496
        f32.mul
        return    
    )

    (func $process_topbottomleftright_pixels (param $index i32) (param $width i32) (result f32)
        (local $temp i32)

        ;; LEFT
            ;; get left px index
            local.get $index    
            i32.const 4
            i32.sub
            ;; set it to temp, temp = left
            i32.load8_u
            local.set $temp             ;; stack empty

        ;; RIGHT
            ;; get right px index
            local.get $index
            i32.const 4
            i32.add
            ;; add its value to temp, temp = left + right
            i32.load8_u
            local.get $temp
            i32.add 
            local.set $temp              ;; stack empty

        ;; TOP
            ;;get top px index
            local.get $index
            local.get $width
            i32.const 4
            i32.mul
            i32.sub
            ;; add its value to temp, temp = left + right + top
            i32.load8_u
            local.get $temp
            i32.add
            local.set $temp              ;; stack empty

        ;; BOTTOM
            ;; get bottom px index
            local.get $index
            local.get $width
            i32.const 4
            i32.mul
            i32.add
            ;; add its value to temp, temp = left + right + top + bottom
            i32.load8_u
            local.get $temp
            i32.add
            local.set $temp               ;; stack empty

        ;; return f32 number = 0.124758 * temp
        local.get $temp
        f32.convert_i32_s
        f32.const 0.124758
        f32.mul
        return        
    )

    (func $process_corner_pixels (param $index i32) (param $width i32) (result f32)
        (local $temp i32)

        ;; TOP-LEFT
            ;; get top-left px index = ( i - 4w) - 4
            local.get $index
            local.get $width
            i32.const 4
            i32.mul
            i32.sub
            i32.const 4
            i32.sub
            ;; set temp = top_left
            i32.load8_u
            local.set $temp             ;; stack empty
        
        ;; TOP-RIGHT
            ;; get top-right px index = ( i - 4w) + 4
            local.get $index
            local.get $width
            i32.const 4
            i32.mul
            i32.sub
            i32.const 4
            i32.add
            ;; add its value to temp, temp = top_left + top_right
            i32.load8_u
            local.get $temp
            i32.add
            local.set $temp             ;; stack empty

        ;; BOTTOM-LEFT
            ;; get bottom-left px index = ( i + 4w) - 4
            local.get $index
            local.get $width
            i32.const 4
            i32.mul
            i32.add
            i32.const 4
            i32.sub
            ;; add its value to temp, temp = top_left + top_right + bottom_left
            i32.load8_u
            local.get $temp
            i32.add
            local.set $temp             ;; stack empty

        ;; BOTTOM-RIGHT
            ;; get bottom-right px index = ( i + 4w ) + 4
            local.get $index
            local.get $width
            i32.const 4
            i32.mul
            i32.add
            i32.const 4
            i32.add
            ;; add its value to temp, temp = top_left + top_right + bottom_left + bottom_right
            i32.load8_u
            local.get $temp
            i32.add
            local.set $temp             ;; stack empty

        ;; return f32 number =  temp * 0.057118
        local.get $temp
        f32.convert_i32_s
        f32.const 0.057118
        f32.mul
        return
    )


)