import { saveAs } from './FileSaver.js';

window.Module({
    canvas: (function() { return document.getElementById('canvas'); })(),
    'print': function(str) { document.getElementById('serial').value += str; },
    'onRuntimeInitialized': (function () {
        this.ccall('remove_disk', null, ['number'], [1]);
        this.FS.close(this.FS.open("disk1.img", "w+"));
        this.FS.truncate("disk1.img", 16777216);
        this.ccall('new_disk', null, ['string', 'number'], ['disk1.img', 1]);
        window.FS = this.FS; // stupid hack?????
        window.ccall = this.ccall; // another stupid hack ????????????????
        document.getElementById("disk1load").onchange = load_file;
        document.getElementById("disk1save").onclick = save_file;
    })
});

let reader = new FileReader();
function load_file() {
    let files = document.getElementById('disk1load').files;
    let file = files[0];
    reader.addEventListener('loadend', insert_disk);
    reader.readAsArrayBuffer(file);
}
function save_file() {
    let data = window.FS.readFile("disk1.img", { encoding: 'binary' });
    let blob = new Blob([data], {type: "applications/octet-stream"});
    saveAs(blob, "disk1.img");
}
function insert_disk(e) {
    let result = reader.result;
    const uint8_view = new Uint8Array(result);

    window.ccall('remove_disk', null, ['number'], [1])
    window.FS.writeFile('disk1.img', uint8_view, { flags: 'w+' })
    window.ccall('new_disk', null, ['string', 'number'], ['disk1.img', 1])
}
