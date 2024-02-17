(module
    (import "js" "mem" (memory $mem 1))

    (export "convertToGrayscale" (func $convertToGrayscale))
    (export "negative" (func $negative))
    (export  "increase_brightness" (func $increase_brightness))
    (export  "decrease_brightness" (func $decrease_brightness))

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