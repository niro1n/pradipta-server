$(function () {
    window.addEventListener("message", function (event) {
        if (event.data.type == "open") {
            PRADIPTARadio.SlideUp();
        }

        if (event.data.type == "close") {
            PRADIPTARadio.SlideDown();
        }
    });

    document.onkeyup = function (data) {
        if (data.key == "Escape") {
            // Escape key
            $.post("https://pradipta-radio/escape", JSON.stringify({}));
        } else if (data.key == "Enter") {
            // Enter key
            $.post(
                "https://pradipta-radio/joinRadio",
                JSON.stringify({
                    channel: $("#channel").val(),
                })
            ).then((data) => {
                if (data.canaccess) {
                    $("#channel").val(data.channel);
                }
            });
        }
    };
});

PRADIPTARadio = {};

$(document).on("click", "#submit", function (e) {
    e.preventDefault();

    $.post(
        "https://pradipta-radio/joinRadio",
        JSON.stringify({
            channel: $("#channel").val(),
        })
    ).then((data) => {
        if (data.canaccess) {
            $("#channel").val(data.channel);
        }
    });
});

$(document).on("click", "#disconnect", function (e) {
    e.preventDefault();

    $.post("https://pradipta-radio/leaveRadio");
});

$(document).on("click", "#volumeUp", function (e) {
    e.preventDefault();

    $.post(
        "https://pradipta-radio/volumeUp",
        JSON.stringify({
            channel: $("#channel").val(),
        })
    );
});

$(document).on("click", "#volumeDown", function (e) {
    e.preventDefault();

    $.post(
        "https://pradipta-radio/volumeDown",
        JSON.stringify({
            channel: $("#channel").val(),
        })
    );
});

$(document).on("click", "#decreaseradiochannel", function (e) {
    e.preventDefault();

    $.post(
        "https://pradipta-radio/decreaseradiochannel",
        JSON.stringify({
            channel: $("#channel").val(),
        })
    ).then((data) => {
        if (data.canaccess) {
            $("#channel").val(data.channel);
        }
    });
});

$(document).on("click", "#increaseradiochannel", function (e) {
    e.preventDefault();

    $.post(
        "https://pradipta-radio/increaseradiochannel",
        JSON.stringify({
            channel: $("#channel").val(),
        })
    ).then((data) => {
        if (data.canaccess) {
            $("#channel").val(data.channel);
        }
    });
});

$(document).on("click", "#poweredOff", function (e) {
    e.preventDefault();

    $.post(
        "https://pradipta-radio/poweredOff",
        JSON.stringify({
            channel: $("#channel").val(),
        })
    );
});

PRADIPTARadio.SlideUp = function () {
    $(".container").css("display", "block");
    $(".radio-container").animate({ bottom: "6vh" }, 250);
};

PRADIPTARadio.SlideDown = function () {
    $(".radio-container").animate({ bottom: "-110vh" }, 400, function () {
        $(".container").css("display", "none");
    });
};
