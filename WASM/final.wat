(module
    (import "js" "mem" (memory $mem 1))
    (export  "cartoon" (func $cartoon))




    
 (func $cartoon (param $ptr i32) (param $width i32) (param $height i32) (param $increase_by i32)
    (local $len i32) 
    (local $i i32)
    (local $pixel i32)
    (local $r i32)
    (local $g i32)
    (local $b i32)
    (local $a i32)
    (local $avg i32)
    ;; Calcular la longitud total de los datos de píxeles
    local.get $width
    local.get $height
    i32.const 4
    i32.mul
    i32.mul
    local.set $len
    ;; Inicializar índice de píxeles
    i32.const 0
    local.set $i
    (loop $loop_start
        ;; Comprobar si hemos procesado todos los píxeles
        local.get $i
        local.get $len
        i32.ge_u
        (if (then (return)))
        ;; Cargar el píxel actual
        local.get $ptr
        local.get $i
        i32.add
        i32.load
        local.set $pixel
        ;; Descomponer el píxel en componentes RGBA
        local.get $pixel
        i32.const 255
        i32.and
        local.set $r
        local.get $pixel
        i32.const 8
        i32.shr_u
        i32.const 255
        i32.and
        local.set $g
        local.get $pixel
        i32.const 16
        i32.shr_u
        i32.const 255
        i32.and
        local.set $b
        local.get $pixel
        i32.const 24
        i32.shr_u
        i32.const 255
        i32.and
        local.set $a
        ;; Calcular el promedio para simplificar el color (efecto grisáceo, base para la simplificación)
        local.get $r
        local.get $g
        local.get $b
        i32.add
        i32.add
        i32.const 3
        i32.div_u
        local.set $avg
        ;; Reasignar colores simplificados (podrías intentar ajustes más complejos aquí)
        local.get $avg
        local.get $increase_by
        i32.add
        local.set $r
        local.get $avg
        local.get $increase_by
        i32.add
        local.set $g
        local.get $avg
        local.get $increase_by
        i32.add
        local.set $b
        ;; Combinar los componentes en un solo valor de píxel
        local.get $a
        i32.const 24
        i32.shl
        local.get $b
        i32.const 16
        i32.shl
        i32.or
        local.get $g
        i32.const 8
        i32.shl
        i32.or
        local.get $r
        i32.or
        local.set $pixel
        ;; Almacenar el píxel modificado
        local.get $ptr
        local.get $i
        i32.add
        local.get $pixel
        i32.store
        ;; Incrementar el índice para procesar el siguiente píxel
        local.get $i
        i32.const 4
        i32.add
        local.set $i
        br $loop_start
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