function pushMessage(msg) {
    $.Notify({
        caption: msg.split("|")[0],
        content: msg.split("|")[1],
        type: 'info',
        timeout: 6000
    });
}