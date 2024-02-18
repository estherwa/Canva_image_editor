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


   


)