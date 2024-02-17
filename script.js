const fileInput = document.querySelector("#file-input");
const fileName = document.querySelector(".file-name");
const buttons = document.querySelectorAll('.button');
const canvas = document.querySelector('#canvas');
const context = canvas.getContext('2d');

// Globals
let imgData;
let data;       // canvas pixels array
let originalData;   // original pixel array of the image
let img;            // image object
let filterTabData; // pixel array for filters tab
let isFilterTabActive = false;
let isToolsTabActive = true;
let brightnessValue = 0;

let imgName;

//WASM =============================================================
const memory = new WebAssembly.Memory({initial : 1});
let bytes;     //WASM memory array

let editorFunctions = {
    grayscale : 0,
    negative: 0,
    decreaseBrightness : 0,
    increaseBrightness : 0,

    blurImage : 0
}

fetch('WASM/final.wasm')
    .then( response => response.arrayBuffer() )
    .then( bytes =>
        WebAssembly.instantiate( bytes, { 
                js : { mem : memory}
        })
    )
    .then(results => {
        editorFunctions.grayscale =  results.instance.exports.convertToGrayscale;
        editorFunctions.negative =  results.instance.exports.negative;


        editorFunctions.decreaseBrightness =  results.instance.exports.decrease_brightness;
        editorFunctions.increaseBrightness =  results.instance.exports.increase_brightness;

    });

// EVENT LISTENERS =================================================
fileInput.addEventListener('change', (e) => {
    let imageFile = e.target.files[0];
    let reader = new FileReader();
    reader.readAsDataURL(imageFile);
    reader.onload = (event) => {
        img = new Image();
        img.src = event.target.result;

        // draw image on canvas
        img.onload = ( e ) => {
            context.clearRect( 0, 0, canvas.width, canvas.height );
            canvas.width = img.width;
            canvas.height = img.height;
            context.drawImage( img, 0, 0, canvas.width, canvas.height);

            imgData = context.getImageData( 0, 0, canvas.width, canvas.height );
            data = imgData.data;
            originalData = context.getImageData( 0, 0, canvas.width, canvas.height ).data;
            filterTabData = context.getImageData( 0, 0, canvas.width, canvas.height ).data;
            growMemory( canvas.width, canvas.height );
            canvasDataToWASM_BytesArr();
            document.querySelector('.brightness').value = 50;
            brightnessValue = 50;
            enableButtons();
        }
    }
    imgName = e.target.files[0].name;
    fileName.innerText = imgName;
})

document.addEventListener('click', (e) => {
    let classlist = e.target.classList;
    // original-image button
    if( classlist.contains('original-image') ){
        putOriginalImageToCanvas();
    }


    // negative
    else if( classlist.contains('negative') ){
        filterTabDataToWASM_BytesArr();
        editorFunctions.negative( canvas.width, canvas.height );
        WASM_BytesArrToCanvasData(0);
        context.putImageData( imgData, 0, 0 );
    }
    // grayscale
    else if( classlist.contains('grayscale') ){
        filterTabDataToWASM_BytesArr();
        editorFunctions.grayscale( canvas.width, canvas.height );
        WASM_BytesArrToCanvasData(0);
        context.putImageData( imgData, 0, 0 );
    }
    else if ((classlist.contains('brightness'))
        || (classlist.contains('decrese_brightness'))) {
        let newBrightnessValue = e.target.value;

        console.log({ newBrightnessValue })
        let changeInValue = -80;
        console.log("hey2", changeInValue)
        if (changeInValue < 0) {
            canvasDataToWASM_BytesArr();
            editorFunctions.decreaseBrightness(canvas.width, canvas.height, -(changeInValue));
            WASM_BytesArrToCanvasData(0);
            context.putImageData(imgData, 0, 0);
        }
        if (changeInValue > 0) {
            canvasDataToWASM_BytesArr();
            editorFunctions.increaseBrightness(canvas.width, canvas.height, changeInValue);
            WASM_BytesArrToCanvasData(0);
            context.putImageData(imgData, 0, 0);
        }
        brightnessValue = 58;
    }


})

document.addEventListener('input', (e) => {
    if( e.target.classList.contains('brightness') ){
        let newBrightnessValue = e.target.value;

        console.log({ newBrightnessValue })
        let changeInValue = (0 - brightnessValue) % 50;
        if( changeInValue < 0 ){
            canvasDataToWASM_BytesArr();
            editorFunctions.decreaseBrightness( canvas.width, canvas.height, -(changeInValue));
            WASM_BytesArrToCanvasData( 0 );
            context.putImageData( imgData, 0, 0 );
        }
        if( changeInValue > 0 ){
            canvasDataToWASM_BytesArr();
            editorFunctions.increaseBrightness( canvas.width, canvas.height, changeInValue );
            WASM_BytesArrToCanvasData( 0 );
            context.putImageData( imgData, 0, 0 );
        }
        brightnessValue = 58;
    }
});

// function definitions======================================================

// copy data from data array ( canvas data ) to WASM memory
function canvasDataToWASM_BytesArr(){
    for( let i = 0; i < data.length; i++){
        bytes[i] = data[i];
    }
}

function filterTabDataToWASM_BytesArr(){
    for( let i = 0; i < filterTabData.length; i++){
        bytes[i] = filterTabData[i];
    }
}

// copy data from WASM memory to data array ( canvas data )
function WASM_BytesArrToCanvasData( offset ){
    for( let i = 0; i < data.length; i++){
        data[i] = bytes[i + offset];
    }
}

function putOriginalImageToCanvas(){
    for( let i = 0; i < data.length; i++){
        data[i] = originalData[i];
        filterTabData[i] = originalData[i];
    }
    context.putImageData( imgData, 0, 0 );
    document.querySelector('.brightness').value = 50;
    brightnessValue = 50;
}

function growMemory( width , height ){
    // if memory required for image is less than present then do nothing
    let requiredBytes = width * height * 8;
    if( requiredBytes < memory.buffer.byteLength ){
        return;
    }
    // if more memory is required
    // one page = 64kB = 64*1024
    let currentPages = memory.buffer.byteLength / ( 64 * 1024);
    let pagesRequired = Math.ceil(requiredBytes / ( 64 * 1024)) - currentPages;
    memory.grow(pagesRequired);
    bytes = new Uint8ClampedArray( memory.buffer );
}

function enableButtons( ){
    buttons.forEach( btn => {
        btn.removeAttribute('disabled');
    });
}
function disableButtons( ){
    buttons.forEach( btn => {
        btn.addAttribute('disabled', '');
    });
}

// UI ==================================================================
const tabs = document.querySelectorAll('[data-tab-target]');
const tabContents = document.querySelectorAll('[data-tab-content]');

tabs.forEach( tab => {
    tab.addEventListener('click', (e) => {
        const target = document.querySelector(tab.dataset.tabTarget);
        tabContents.forEach( tabContent => {
            tabContent.classList.remove('active');
        })
        tabs.forEach( tab => {
            tab.classList.remove('active');
        })
        target.classList.add('active');
        tab.classList.add('active');

        if( tab.classList.contains('filters') && !isFilterTabActive ){
            isFilterTabActive = true;
            isToolsTabActive = false;
            filterTabData = context.getImageData( 0, 0, canvas.width, canvas.height ).data;
        }
        if( tab.classList.contains('tools') && !isToolsTabActive ){
            isFilterTabActive = false;
            isToolsTabActive = true;
            // copy pixels from filterTabData to data array for tools tab
            // if changes are not applied in filters tab, the unchanged data gets copied
            for (let i = 0; i < filterTabData.length; i++) {
                data[i] = filterTabData[i];
            }
            context.putImageData( imgData, 0, 0);
        }
    })
})