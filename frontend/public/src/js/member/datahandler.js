function generateApiUrl(root) {
    var page = parse("page");
    if(page == "Not found") page = "1";
    var key = getApiKey();
    var result = root + "?page=" + page + "&key=" + key + "&format=json";
    return result;
}
function parse(val) {
    var result = "Not found";
    var tmp = [];
    var items = window.location.search.replace("?", "").split("&");
    for (var index = 0; index < items.length; index++) {
        tmp = items[index].split("=");
        if (tmp[0] === val) result = decodeURIComponent(tmp[1]);
    }
    return result;
}