var photos = [{
        url: "i.jpeg",
        id: 1
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 2
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 3
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 4
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 5
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 6
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 7
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 8
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 9
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 10
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 11
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 12
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 13
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 14
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 15
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 16
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 17
    },
    {
        url: "i.jpeg",
        video: "i.webm",
        id: 18
    }
]

var currentCategory = "";

window.addEventListener('message', (event) => {
    var data = event.data;
    switch (data.action) {
        case "open":
            gotoAllCategy();
            $("body").show("fade");
            $(".main-wrapper").show("fade");
            $(".arkaplan").show("fade");
            $(".cam").hide("fade");
            $(".drone-help").hide("fade");
            $(".camera-help").hide("fade");
            $(".image").css("background-size", "cover");
            $(".fullvid").hide("fade");
            $(".fullimg").hide("fade");
            photos = data.data;
            console.log(photos);
            Init(data.data);
            break;
        case "cam":
            $("body").show("fade");
            $(".main-wrapper").hide("fade");
            $(".arkaplan").hide("fade");
            $(".cam").show("fade");
            $(".drone-help").show("fade");
            $(".camera-help").show("fade");
            break;
        case "camkapa":
            $("body").hide("fade");
            $(".main-wrapper").hide("fade");
            $(".arkaplan").hide("fade");
            $(".cam").hide("fade");
            $(".drone-help").hide("fade");
            $(".camera-help").hide("fade");
            break;
        case "takedphoto":
            $(".flash").css("background-color", "#fff");
            $(".flash").show("fade");
            $(".taked_photo").hide("fade");
            break;
        case "photoinfo":
            $(".flash").show("fade");
            $(".flash").css("background-color", "#000");
            $(".drone-help").hide("fade");
            $(".camera-help").hide("fade");
            // $(".taked_photo").css({ "background": "url(" + data.img + ")", "background-size": "cover" });
            $(".taked_photo").show("fade");
            break;
        case "recording":
            $(".left_up").css({ "background": "url(../img/rec.gif)", "background-size": "cover" });
            break;
        case "stoprec":
            $(".left_up").css({ "background": "url(../img/sol_ust.png)", "background-size": "cover" });
            break;
    }
});;

var [curpage, maxpage, pages, curdata] = [0, 888, {}, {}];

function gotoAllCategy() {
    var curpage = 0;
    $(".layout-1").html("");
    maxpage = truncate(photos.length / 888);
    curdata = photos;
    console.log(curpage)
    if ((photos.length / 888) != 0) {
        pages = paginate(photos, 888);
        $.each(pages[0], function(i, v) {
            date = new Date(v.date);
            x = "";
            if (v.video) { x = 'data-video="' + v.video + '"'; }
            $(".layout-1").append(`
            <div class="photo p-${v.id}" data-url="${v.url}" ${x}>
                <div class="image"  data-url="${v.url}" ${x} style="background: url(${v.url});"></div>
                <p class="date">${date.toLocaleDateString('en-US')}</p>

            </div>
            `);
        });
    }
    $(".page-helpers h1").html(`${curpage}/${maxpage}`);
}

$("#all").click(function(e) {
    gotoAllCategy();
});

$("#recent").click(function(e) {
    $(".layout-1").html("");
    maxpage = truncate(photos.length / 888);
    curdata = photos;
    if ((photos.length / 888) != 0) {
        pages = paginate(photos, 888);
        $.each(pages[curpage], function(i, v) {
            if (v.category == "recent") {
                date = new Date(v.date);
                x = "";
                if (v.video) { x = 'data-video="' + v.video + '"'; }
                $(".layout-1").append(`
                <div class="photo p-${v.id}" data-url="${v.url}" ${x}>
                    <div class="image"  data-url="${v.url}" ${x} style="background: url(${v.url});"></div>
                    <p class="date">${date.toLocaleDateString('en-US')}</p>
                </div>
                `);
            }
        });
    }
    $(".page-helpers h1").html(`${curpage}/${maxpage}`);
});

$("#videos").click(function(e) {
    $(".layout-1").html("");
    maxpage = truncate(photos.length / 888);
    curdata = photos;
    if ((photos.length / 888) != 0) {
        pages = paginate(photos, 888);
        $.each(pages[curpage], function(i, v) {
            if (v.category == "videos") {
                date = new Date(v.date);
                x = "";
                if (v.video) { x = 'data-video="' + v.video + '"'; }
                $(".layout-1").append(`
                <div class="photo p-${v.id}" data-url="${v.url}" ${x}>
                    <div class="image"  data-url="${v.url}" ${x} style="background: url(${v.url});"></div>
                    <p class="date">${date.toLocaleDateString('en-US')}</p>
                </div>
                `);
            }
        });
    }
    $(".page-helpers h1").html(`${curpage}/${maxpage}`);
});

$("#folders").click(function(e) {
    $(".layout-1").html("");
    maxpage = truncate(photos.length / 888);
    curdata = photos;
    if ((photos.length / 888) != 0) {
        pages = paginate(photos, 888);
        $.each(pages[curpage], function(i, v) {
            if (v.category == "folders") {
                date = new Date(v.date);
                x = "";
                if (v.video) { x = 'data-video="' + v.video + '"'; }
                $(".layout-1").append(`
                <div class="photo p-${v.id}" data-url="${v.url}" ${x}>
                    <div class="image"  data-url="${v.url}" ${x} style="background: url(${v.url});"></div>
                    <p class="date">${date.toLocaleDateString('en-US')}</p>
                </div>
                `);
            }
        });
    }
    $(".page-helpers h1").html(`${curpage}/${maxpage}`);
});

$("#documents").click(function(e) {
    $(".layout-1").html("");
    maxpage = truncate(photos.length / 888);
    curdata = photos;
    if ((photos.length / 888) != 0) {
        pages = paginate(photos, 888);
        $.each(pages[curpage], function(i, v) {
            if (v.category == "documents") {
                date = new Date(v.date);
                x = "";
                if (v.video) { x = 'data-video="' + v.video + '"'; }
                $(".layout-1").append(`
                <div class="photo p-${v.id}" data-url="${v.url}" ${x}>
                    <div class="image"  data-url="${v.url}" ${x} style="background: url(${v.url});"></div>
                    <p class="date">${date.toLocaleDateString('en-US')}</p>
                </div>
                `);
            }
        });
    }
    $(".page-helpers h1").html(`${curpage}/${maxpage}`);
});

$("#switchToAll").click(function(e) {
    let zvideo = $(".fullvid").data("video");
    let imgUrl = $(".fullimg").data("url");
    let url = imgUrl || zvideo; // imgUrl veya zvideo değerini url olarak ayarla
    console.log(url);
    // Kategori değişikliği
    $.each(photos, function(i, v) {
        if (v.url == url) {
            photos[i].category = "all";
        }
    })
    $.post("https://exter-albums/changeCategory", JSON.stringify({ url: url, category: "all" }));
    $(".fullimg").fadeOut(500);
    $(".fullvid").fadeOut(500);
    $(".category-selector").fadeOut(500);
    gotoAllCategy();
    __close__();
});

$("#switchToRecent").click(function(e) {
    let zvideo = $(".fullvid").data("video");
    let imgUrl = $(".fullimg").data("url");
    let url = imgUrl || zvideo; // imgUrl veya zvideo değerini url olarak ayarla
    console.log(url);
    // Kategori değişikliği
    $.each(photos, function(i, v) {
        if (v.url == url) {
            photos[i].category = "recent";
        }
    })
    $.post("https://exter-albums/changeCategory", JSON.stringify({ url: url, category: "recent" }));
    $(".fullimg").fadeOut(500);
    $(".fullvid").fadeOut(500);
    $(".category-selector").fadeOut(500);
    gotoAllCategy();
    __close__();
});

$("#switchToVideos").click(function(e) {
    let zvideo = $(".fullvid").data("video");
    let imgUrl = $(".fullimg").data("url");
    let url = imgUrl || zvideo; // imgUrl veya zvideo değerini url olarak ayarla
    console.log(url);
    // Kategori değişikliği
    $.each(photos, function(i, v) {
        if (v.url == url) {
            photos[i].category = "videos";
        }
    })
    $.post("https://exter-albums/changeCategory", JSON.stringify({ url: url, category: "videos" }));
    $(".fullimg").fadeOut(500);
    $(".fullvid").fadeOut(500);
    $(".category-selector").fadeOut(500);
    gotoAllCategy();
    __close__();
});

$("#switchToFolders").click(function(e) {
    let zvideo = $(".fullvid").data("video");
    let imgUrl = $(".fullimg").data("url");
    let url = imgUrl || zvideo; // imgUrl veya zvideo değerini url olarak ayarla
    console.log(url);
    // Kategori değişikliği
    $.each(photos, function(i, v) {
        if (v.url == url) {
            photos[i].category = "folders";
        }
    })
    $.post("https://exter-albums/changeCategory", JSON.stringify({ url: url, category: "folders" }));
    $(".fullimg").fadeOut(500);
    $(".fullvid").fadeOut(500);
    $(".category-selector").fadeOut(500);
    gotoAllCategy();
    __close__();
});

$("#switchToDocuments").click(function(e) {
    let zvideo = $(".fullvid").data("video");
    let imgUrl = $(".fullimg").data("url");
    let url = imgUrl || zvideo; // imgUrl veya zvideo değerini url olarak ayarla
    console.log(url);
    // Kategori değişikliği
    $.each(photos, function(i, v) {
        if (v.url == url) {
            photos[i].category = "documents";
        }
    });
    // POST isteği gönderme
    $.post("https://exter-albums/changeCategory", JSON.stringify({ url: url, category: "documents" }));
    // Animasyonlar
    $(".fullimg").fadeOut(500);
    $(".fullvid").fadeOut(500);
    $(".category-selector").fadeOut(500);
    gotoAllCategy();
    __close__();
});

$("#showall").click(function(e) {
    gotoAllCategy();
    $(".category-selector").fadeOut(500);
    $(".fullimg").fadeOut(500);
    $(".fullvid").fadeOut(500);
});

$("#paylasfullimg").click(function(e) {
    $(".fullimg").fadeOut(500);
    $(".fullvid").fadeOut(500);
    share = $(".fullimg").data("id");
    $(".share").show("fade");
    $(".players").html("");
    $.post("https://exter-albums/getPlayers", {}, function(data, textStatus, jqXHR) {
        $.each(data, function(i, v) {
            $(".players").append(`
                <div class="player" data-source="${v.source}" data-share="${share}">
                    <img src="./images/mail-icon.svg" class="mail-icon">
                    <p class="player-name"> <b>${v.source}</b> <br> ${v.name}</p>
                </div>
            `);
        });
    });
})
$("#switcher").click(function(e) {
    $(".category-selector").fadeIn(250);
});
Init = (data) => {
        $(".layout-1").html("");
        maxpage = truncate(data.length / 8);
        curdata = data;
        if ((data.length / 8) != 0) {
            pages = paginate(data, 8);
            $.each(pages[curpage], function(i, v) {
                date = new Date(v.date);
                x = "";
                if (v.video) { x = 'data-video="' + v.video + '"'; }
                $(".layout-1").append(`
                <div class="photo p-${v.id}" data-url="${v.url}" ${x}>
                    <div class="image"  data-url="${v.url}" ${x} style="background: url(${v.url});"></div>
                    <p class="date">${date.toLocaleDateString('en-US')}</p>
                </div>
                `);
            });
        }
        $(".page-helpers h1").html(`${curpage}/${maxpage}`);
    }
    // Init(photos);

$("#silfullimg").click(function(e) {
    console.log($(".fullimg").data("url"))
    e.stopPropagation();
    const data = $(this).data("id");
    curdata.splice(GetDataIndex(parseInt(data)), 1);
    $(".p-" + data).hide("fade");
    setTimeout(() => {
        $(".p-" + data).remove();
        Init(curdata);
    }, 1000);
    $.post("https://exter-albums/deletefullimg", JSON.stringify($(".fullimg").data("url")));
    $(".fullimg").fadeOut(500);
    __close__();
});

var bigeri = false;
$(document).on("click", ".photo", function() {
    const photo = $(this).data("url");
    const video = $(this).data("video");
    $('.fullimg').data('url', photo);
    $('.fullimg').data('url', video);
    $(".fullimg").css("background-image", "url(" + photo + ")");
    // $(".fullimg").css({ "background": "url(" + photo + ")" })
    $(".fullimg").css("background-size", "cover !important");
    $(".fullimg").show("fade");
    bigeri = true;
    if (video) {
        $("video.fullvid source").attr("src", video);
        $("video.fullvid")[0].load();
        $(".fullvid").css("background-size", "cover !important");
        $(".fullvid").show("fade");
        // $(".fullimg").html(`
        //     <video controls>
        //         <source src="${video}" type="video/mp4">
        //     </video>
        //     <div class="actions">
        //         <div id="paylasfullimg" class="action" style="border-top-left-radius: 1vw; border-top-right-radius: 1vw;">Share <img src="./images/share-logo.svg" class="act-icon2"></div>
        //         <div class="action" id="switcher">Switch Category <img src="./images/category.svg" class="act-icon2"></div>
        //         <div class="action" id="showall">Show All Photos <img src="./images/allphoto.svg" class="act-icon2"></div>
        //         <div id="silfullimg" class="action" style="border-bottom-left-radius: 1vw; border-bottom-right-radius: 1vw;">Cancel <img src="./images/remove.svg" class="act-icon"> </div>
        //     </div>
        //     `);
    }

});

$(document).on("click", ".ileri", function() {
    if (maxpage <= curpage) { return; }
    curpage = curpage + 1;
    Init(curdata);
});

$(document).on("click", ".geri", function() {
    if (curpage <= 0) { return; }
    curpage = curpage - 1;
    Init(curdata);
});

$(document).on("click", ".save_photo", function() {
    $.post("https://exter-albums/savePhoto", JSON.stringify({}), function(data, textStatus, jqXHR) {

    });
    $(".flash").hide("fade");
    $(".taked_photo").hide("fade");
    __close__();
});

$(document).on("click", ".cancel_photo", function() {
    $.post("https://exter-albums/rePhoto");
    $(".flash").hide("fade");
    $(".taked_photo").hide("fade");
    __close__();
});

var share = 0;
$(document).on("click", ".paylas", function(e) {
    e.stopPropagation();
    share = $(this).data("id");
    $(".share").show("fade");
    $(".players").html("");
    $.post("https://exter-albums/getPlayers", {}, function(data, textStatus, jqXHR) {
        $.each(data, function(i, v) {
            $(".players").append(`
                <div class="player" data-source="${v.source}" data-share="${share}">
                    <img src="./images/mail-icon.svg" class="mail-icon">
                    <p class="player-name"> <b>${v.source}</b> <br> ${v.name}</p>
                </div>
            `);
        });
    });
});

$(document).on("click", ".player", function() {
    const [source, share] = [$(this).data("source"), $(this).data("share")];
    $.post("https://exter-albums/sendToPlayer", JSON.stringify({ source: source, share: share }));
    $(".share").hide("fade");
});

$(document).on("click", ".share button", function() {
    $(".share").hide("fade");
});

$(document).on("click", ".sil", function(e) {
    e.stopPropagation();
    const data = $(this).data("id");
    curdata.splice(GetDataIndex(parseInt(data)), 1);
    $(".p-" + data).hide("fade");
    setTimeout(() => {
        $(".p-" + data).remove();
        Init(curdata);
    }, 1000);
    $.post("https://exter-albums/delete", JSON.stringify(data));

});



function GetDataIndex(id) {
    for (let i = 0; i < curdata.length; i++) {
        if (curdata[i].id == id) {
            return i;
        }
    }
}

print = (i) => { console.log(i); }

function paginate(arr, size) {
    return arr.reduce((acc, val, i) => {
        let idx = Math.floor(i / size)
        let page = acc[idx] || (acc[idx] = [])
        page.push(val)
        return acc
    }, [])
}

function truncate(value) {
    if (value < 0) { return Math.ceil(value); }
    return Math.floor(value);
}


__close__ = () => {
    $.post("https://exter-albums/close");
    $(".main-wrapper").hide("fade");
    $(".arkaplan").hide("fade");
}

$(document).on('keydown', function() {
    switch (event.keyCode) {
        case 27:
            if (bigeri == true) {

                bigeri = false;
                $(".fullimg").hide("fade");
                $(".fullvid").hide("fade");
                return;
            }
            __close__();
            break;
    }
});

$(document).on("click", ".kapat", __close__);

$(document).ready(function() {
    $("#l1").click(function() {
        $(".photo").css({
            "position": "relative",
            "float": "left",
            "margin-left": "1vw",
            "margin-bottom": "1vw",
            "width": "4.5833vw",
            "height": "5.8333vw",
            "transition": "all 0.4s",
            "cursor": "pointer",

        });

        $(".image").css({
            "position": "absolute",
            "top": "0vw",
            "left": "0vw",
            "height": "4.5833vw",
            "width": "4.5833vw",
            "background-size": "cover",
            "background-repeat": "no-repeat"
        });

        $(".date").css({
            "position": "absolute",
            "font-style": "normal",
            "font-weight": "500",
            "top": "4.3vw",
            "width": "4.5833vw",
            "text-align": "center",
            "font-size": ".625vw",
            "color": "#232526"
        });

        $(".fa-share").css({
            "position": "absolute",
            "font-size": "0.5vw",
            "top": "0.2vw",
            "left": "4vw",
            "color": "#017AFF"
        });

        $(".fa-trash").css({
            "position": "absolute",
            "font-size": "0.5vw",
            "top": "0.9vw",
            "left": "4vw",
            "color": "#017AFF"
        });
    });
    $("#l2").click(function() {
        $(".photo").css({
            "position": "relative",
            "float": "left",
            "margin-left": "0.2vw",
            "margin-bottom": "0.2vw",
            "width": "20.375vw",
            "height": "1.1458vw",
            "transition": "all 0.4s",
            "cursor": "pointer"
        });

        $(".image").css({
            "position": "absolute",
            "top": "0.18vw",
            "left": "0.3vw",
            "height": "0.8vw",
            "width": "0.8vw",
            "background-size": "cover",
            "background-repeat": "no-repeat"
        });

        $(".date").css({
            "position": "absolute",
            "font-style": "normal",
            "font-weight": "500",
            "top": "-0.44vw",
            "left": "1vw",
            "width": "4.5833vw",
            "text-align": "center",
            "font-size": ".625vw",
            "color": "#232526"
        });

        $(".fa-share").css({
            "position": "absolute",
            "font-size": "0.5vw",
            "top": "0.34vw",
            "left": "18.5vw",
            "color": "#232526"
        });

        $(".fa-trash").css({
            "position": "absolute",
            "font-size": "0.5vw",
            "top": "0.34vw",
            "left": "19.5vw",
            "color": "#232526"
        });
    });
    $("#l3").click(function() {
        $(".photo").css({
            "position": "relative",
            "float": "left",
            "margin-left": "0.2vw",
            "margin-bottom": "0.2vw",
            "width": "12.375vw",
            "height": "19.1458vw",
            "transition": "all 0.4s",
            "cursor": "pointer"
        });

        $(".image").css({
            "position": "absolute",
            "top": "1vw",
            "left": "1.25vw",
            "height": "10vw",
            "width": "10vw",
            "background-size": "cover",
            "background-repeat": "no-repeat"
        });

        $(".date").css({
            "position": "absolute",
            "font-style": "normal",
            "font-weight": "500",
            "top": "10.5vw",
            "left": "0vw",
            "width": "12.375vw",
            "text-align": "center",
            "font-size": "1vw",
            "color": "#232526"
        });

        $(".fa-share").css({
            "position": "absolute",
            "font-size": "1vw",
            "top": "15vw",
            "left": "3.5vw",
            "color": "#232526"
        });

        $(".fa-trash").css({
            "position": "absolute",
            "font-size": "1vw",
            "top": "15vw",
            "left": "8vw",
            "color": "#232526"
        });
    });
    $("#l4").click(function() {
        $(".photo").css({
            "position": "relative",
            "float": "left",
            "margin-left": "0.2vw",
            "margin-bottom": "0.2vw",
            "width": "36.8vw",
            "height": "15.1458vw",
            "transition": "all 0.4s",
            "cursor": "pointer"
        });

        $(".image").css({
            "position": "absolute",
            "top": "1vw",
            "left": "1.25vw",
            "height": "10vw",
            "width": "34.4vw",
            "background-size": "cover",
            "background-repeat": "no-repeat"
        });

        $(".date").css({
            "position": "absolute",
            "font-style": "normal",
            "font-weight": "500",
            "top": "10.5vw",
            "left": "0vw",
            "width": "36.8vw",
            "text-align": "center",
            "font-size": "1vw",
            "color": "#232526"
        });

        $(".fa-share").css({
            "position": "absolute",
            "font-size": "0.7vw",
            "top": "11.5vw",
            "left": "33.8vw",
            "color": "#232526",
            "z-index": "123123213123123122132"
        });

        $(".fa-trash").css({
            "position": "absolute",
            "font-size": "0.7vw",
            "top": "11.5vw",
            "left": "35vw",
            "color": "#232526",
            "z-index": "1233213123212132"
        });
    });
});

// $(function() {
//     function display(bool) {
//         if (bool) {
//             $(".drone-help").show();
//         } else {
//             $(".drone-help").hide();
//         }
//     }

//     display(false)

//     window.addEventListener('message', function(event) {
//         var item = event.data;
//         if (item.type === "drone") {
//             if (item.status == true) {
//                 display(true)
//             } else {
//                 display(false)
//             }
//         }
//     })

// });


// $(function() {
//     function display(bool) {
//         if (bool) {
//             $(".camera-help").show();
//         } else {
//             $(".camera-help").hide();
//         }
//     }

//     display(false)

//     window.addEventListener('message', function(event) {
//         var item = event.data;
//         if (item.type === "camera") {
//             if (item.status == true) {
//                 display(true)
//             } else {
//                 display(false)
//             }
//         }
//     })

// });

window.addEventListener('message', (event) => {
    let item = event.data;
    if (item.type === 'camera') {
        $(".camera-help").show();
        $(".drone-help").hide();
    }
})

window.addEventListener('message', (event) => {
    let item = event.data;
    if (item.type === 'drone') {
        $(".camera-help").hide();
        $(".drone-help").show();
    }
})

$(document).ready(function() {
    $(".search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".photo").filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
    });
});