PRADIPTA = {}
PRADIPTA.Phone = {}
PRADIPTA.Screen = {}
PRADIPTA.Phone.Functions = {}
PRADIPTA.Phone.Animations = {}
PRADIPTA.Phone.Notifications = {}
PRADIPTA.Phone.ContactColors = {
    0: "#9b59b6",
    1: "#3498db",
    2: "#e67e22",
    3: "#e74c3c",
    4: "#1abc9c",
    5: "#9c88ff",
}

PRADIPTA.Phone.Data = {
    currentApplication: null,
    PlayerData: {},
    Applications: {},
    IsOpen: false,
    CallActive: false,
    MetaData: {},
    PlayerJob: {},
    AnonymousCall: false,
}

PRADIPTA.Phone.Data.MaxSlots = 16;

OpenedChatData = {
    number: null,
}

var CanOpenApp = true;
var up = false

function IsAppJobBlocked(joblist, myjob) {
    var retval = false;
    if (joblist.length > 0) {
        $.each(joblist, function(i, job){
            if (job == myjob && PRADIPTA.Phone.Data.PlayerData.job.onduty) {
                retval = true;
            }
        });
    }
    return retval;
}

PRADIPTA.Phone.Functions.SetupApplications = function(data) {
    PRADIPTA.Phone.Data.Applications = data.applications;

    var i;
    for (i = 1; i <= PRADIPTA.Phone.Data.MaxSlots; i++) {
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+i+'"]');
        $(applicationSlot).html("");
        $(applicationSlot).css({
            "background-color":"transparent"
        });
        $(applicationSlot).prop('title', "");
        $(applicationSlot).removeData('app');
        $(applicationSlot).removeData('placement')
    }

    $.each(data.applications, function(i, app){
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');
        var blockedapp = IsAppJobBlocked(app.blockedjobs, PRADIPTA.Phone.Data.PlayerJob.name)

        if ((!app.job || app.job === PRADIPTA.Phone.Data.PlayerJob.name) && !blockedapp) {
            $(applicationSlot).css({"background-color":app.color});
            var icon = '<i class="ApplicationIcon '+app.icon+'" style="'+app.style+'"></i>';
            if (app.app == "meos") {
                icon = '<img src="./img/politie.png" class="police-icon">';
            }
            $(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div>');
            $(applicationSlot).prop('title', app.tooltipText);
            $(applicationSlot).data('app', app.app);

            if (app.tooltipPos !== undefined) {
                $(applicationSlot).data('placement', app.tooltipPos)
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
}

PRADIPTA.Phone.Functions.SetupAppWarnings = function(AppData) {
    $.each(AppData, function(i, app){
        var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');

        if (app.Alerts > 0) {
            $(AppObject).html(app.Alerts);
            $(AppObject).css({"display":"block"});
        } else {
            $(AppObject).css({"display":"none"});
        }
    });
}

PRADIPTA.Phone.Functions.IsAppHeaderAllowed = function(app) {
    var retval = true;
    $.each(Config.HeaderDisabledApps, function(i, blocked){
        if (app == blocked) {
            retval = false;
        }
    });
    return retval;
}

$(document).on('click', '.phone-application', function(e){
    e.preventDefault();
    var PressedApplication = $(this).data('app');
    var AppObject = $("."+PressedApplication+"-app");

    if (AppObject.length !== 0) {
        if (CanOpenApp) {
            if (PRADIPTA.Phone.Data.currentApplication == null) {
                PRADIPTA.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
                PRADIPTA.Phone.Functions.ToggleApp(PressedApplication, "block");

                if (PRADIPTA.Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
                    PRADIPTA.Phone.Functions.HeaderTextColor("black", 300);
                }

                PRADIPTA.Phone.Data.currentApplication = PressedApplication;

                if (PressedApplication == "settings") {
                    $("#myPhoneNumber").text(PRADIPTA.Phone.Data.PlayerData.charinfo.phone);
                    $("#mySerialNumber").text("PRADIPTA-" + PRADIPTA.Phone.Data.PlayerData.metadata["phonedata"].SerialNumber);
                } else if (PressedApplication == "twitter") {
                    $.post('https://pradipta-phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
                        PRADIPTA.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
                    })
                    $.post('https://pradipta-phone/GetHashtags', JSON.stringify({}), function(Hashtags){
                        PRADIPTA.Phone.Notifications.LoadHashtags(Hashtags)
                    })
                    if (PRADIPTA.Phone.Data.IsOpen) {
                        $.post('https://pradipta-phone/GetTweets', JSON.stringify({}), function(Tweets){
                            PRADIPTA.Phone.Notifications.LoadTweets(Tweets);
                        });
                    }
                } else if (PressedApplication == "bank") {
                    PRADIPTA.Phone.Functions.DoBankOpen();
                    $.post('https://pradipta-phone/GetBankContacts', JSON.stringify({}), function(contacts){
                        PRADIPTA.Phone.Functions.LoadContactsWithNumber(contacts);
                    });
                    $.post('https://pradipta-phone/GetInvoices', JSON.stringify({}), function(invoices){
                        PRADIPTA.Phone.Functions.LoadBankInvoices(invoices);
                    });
                } else if (PressedApplication == "whatsapp") {
                    $.post('https://pradipta-phone/GetWhatsappChats', JSON.stringify({}), function(chats){
                        PRADIPTA.Phone.Functions.LoadWhatsappChats(chats);
                    });
                } else if (PressedApplication == "phone") {
                    $.post('https://pradipta-phone/GetMissedCalls', JSON.stringify({}), function(recent){
                        PRADIPTA.Phone.Functions.SetupRecentCalls(recent);
                    });
                    $.post('https://pradipta-phone/GetSuggestedContacts', JSON.stringify({}), function(suggested){
                        PRADIPTA.Phone.Functions.SetupSuggestedContacts(suggested);
                    });
                    $.post('https://pradipta-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "phone"
                    }));
                } else if (PressedApplication == "mail") {
                    $.post('https://pradipta-phone/GetMails', JSON.stringify({}), function(mails){
                        PRADIPTA.Phone.Functions.SetupMails(mails);
                    });
                    $.post('https://pradipta-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "mail"
                    }));
                } else if (PressedApplication == "advert") {
                    $.post('https://pradipta-phone/LoadAdverts', JSON.stringify({}), function(Adverts){
                        PRADIPTA.Phone.Functions.RefreshAdverts(Adverts);
                    })
                } else if (PressedApplication == "garage") {
                    $.post('https://pradipta-phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
                        SetupGarageVehicles(Vehicles);
                    })
                } else if (PressedApplication == "crypto") {
                    $.post('https://pradipta-phone/GetCryptoData', JSON.stringify({
                        crypto: "pradiptait",
                    }), function(CryptoData){
                        SetupCryptoData(CryptoData);
                    })

                    $.post('https://pradipta-phone/GetCryptoTransactions', JSON.stringify({}), function(data){
                        RefreshCryptoTransactions(data);
                    })
                } else if (PressedApplication == "racing") {
                    $.post('https://pradipta-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                        SetupRaces(Races);
                    });
                } else if (PressedApplication == "houses") {
                    $.post('https://pradipta-phone/GetPlayerHouses', JSON.stringify({}), function(Houses){
                        SetupPlayerHouses(Houses);
                    });
                    $.post('https://pradipta-phone/GetPlayerKeys', JSON.stringify({}), function(Keys){
                        $(".house-app-mykeys-container").html("");
                        if (Keys.length > 0) {
                            $.each(Keys, function(i, key){
                                var elem = '<div class="mykeys-key" id="keyid-'+i+'"><span class="mykeys-key-label">' + key.HouseData.adress + '</span> <span class="mykeys-key-sub">Click to set GPS</span> </div>';
                                $(".house-app-mykeys-container").append(elem);
                                $("#keyid-"+i).data('KeyData', key);
                            });
                        }
                    });
                } else if (PressedApplication == "meos") {
                    SetupMeosHome();
                } else if (PressedApplication == "lawyers") {
                    $.post('https://pradipta-phone/GetCurrentLawyers', JSON.stringify({}), function(data){
                        SetupLawyers(data);
                    });
                } else if (PressedApplication == "store") {
                    $.post('https://pradipta-phone/SetupStoreApps', JSON.stringify({}), function(data){
                        SetupAppstore(data);
                    });
                } else if (PressedApplication == "trucker") {
                    $.post('https://pradipta-phone/GetTruckerData', JSON.stringify({}), function(data){
                        SetupTruckerInfo(data);
                    });
                }
                else if (PressedApplication == "gallery") {
                    $.post('https://pradipta-phone/GetGalleryData', JSON.stringify({}), function(data){
                        setUpGalleryData(data);
                    });
                }
                else if (PressedApplication == "camera") {
                    $.post('https://pradipta-phone/TakePhoto', JSON.stringify({}),function(url){
                        setUpCameraApp(url)
                    })
                    PRADIPTA.Phone.Functions.Close();
                }


            }
        }
    } else {
        if (PressedApplication != null){
            PRADIPTA.Phone.Notifications.Add("fas fa-exclamation-circle", "System", PRADIPTA.Phone.Data.Applications[PressedApplication].tooltipText+" is not available!")
        }
    }
});

$(document).on('click', '.mykeys-key', function(e){
    e.preventDefault();

    var KeyData = $(this).data('KeyData');

    $.post('https://pradipta-phone/SetHouseLocation', JSON.stringify({
        HouseData: KeyData
    }))
});

$(document).on('click', '.phone-home-container', function(event){
    event.preventDefault();

    if (PRADIPTA.Phone.Data.currentApplication === null) {
        PRADIPTA.Phone.Functions.Close();
    } else {
        PRADIPTA.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        PRADIPTA.Phone.Animations.TopSlideUp('.'+PRADIPTA.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            PRADIPTA.Phone.Functions.ToggleApp(PRADIPTA.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        PRADIPTA.Phone.Functions.HeaderTextColor("white", 300);

        if (PRADIPTA.Phone.Data.currentApplication == "whatsapp") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (PRADIPTA.Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});

                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');

                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');

                    CurrentTab = "accounts";
                }, 400)
            }
        } else if (PRADIPTA.Phone.Data.currentApplication == "meos") {
            $(".meos-alert-new").remove();
            setTimeout(function(){
                $(".meos-recent-alert").removeClass("noodknop");
                $(".meos-recent-alert").css({"background-color":"#004682"});
            }, 400)
        }

        PRADIPTA.Phone.Data.currentApplication = null;
    }
});

PRADIPTA.Phone.Functions.Open = function(data) {
    PRADIPTA.Phone.Animations.BottomSlideUp('.container', 300, 0);
    PRADIPTA.Phone.Notifications.LoadTweets(data.Tweets);
    PRADIPTA.Phone.Data.IsOpen = true;
}

PRADIPTA.Phone.Functions.ToggleApp = function(app, show) {
    $("."+app+"-app").css({"display":show});
}

PRADIPTA.Phone.Functions.Close = function() {

    if (PRADIPTA.Phone.Data.currentApplication == "whatsapp") {
        setTimeout(function(){
            PRADIPTA.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            PRADIPTA.Phone.Animations.TopSlideUp('.'+PRADIPTA.Phone.Data.currentApplication+"-app", 400, -160);
            $(".whatsapp-app").css({"display":"none"});
            PRADIPTA.Phone.Functions.HeaderTextColor("white", 300);

            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            PRADIPTA.Phone.Data.currentApplication = null;
        }, 500)
    } else if (PRADIPTA.Phone.Data.currentApplication == "meos") {
        $(".meos-alert-new").remove();
        $(".meos-recent-alert").removeClass("noodknop");
        $(".meos-recent-alert").css({"background-color":"#004682"});
    }

    PRADIPTA.Phone.Animations.BottomSlideDown('.container', 300, -70);
    $.post('https://pradipta-phone/Close');
    PRADIPTA.Phone.Data.IsOpen = false;
}

PRADIPTA.Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
    $(".phone-header").animate({color: newColor}, Timeout);
}

PRADIPTA.Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout);
}

PRADIPTA.Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

PRADIPTA.Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout);
}

PRADIPTA.Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

PRADIPTA.Phone.Notifications.Add = function(icon, title, text, color, timeout) {
    $.post('https://pradipta-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (timeout == null && timeout == undefined) {
                timeout = 1500;
            }
            if (PRADIPTA.Phone.Notifications.Timeout == undefined || PRADIPTA.Phone.Notifications.Timeout == null) {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else if (color == "default" || color == null || color == undefined) {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!PRADIPTA.Phone.Data.IsOpen) {
                    PRADIPTA.Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                PRADIPTA.Phone.Animations.TopSlideDown(".phone-notification-container", 200, 8);
                if (icon !== "politie") {
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                } else {
                    $(".notification-icon").html('<img src="./img/politie.png" class="police-icon-notify">');
                }
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (PRADIPTA.Phone.Notifications.Timeout !== undefined || PRADIPTA.Phone.Notifications.Timeout !== null) {
                    clearTimeout(PRADIPTA.Phone.Notifications.Timeout);
                }
                PRADIPTA.Phone.Notifications.Timeout = setTimeout(function(){
                    PRADIPTA.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!PRADIPTA.Phone.Data.IsOpen) {
                        PRADIPTA.Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    PRADIPTA.Phone.Notifications.Timeout = null;
                }, timeout);
            } else {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!PRADIPTA.Phone.Data.IsOpen) {
                    PRADIPTA.Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                $(".notification-icon").html('<i class="'+icon+'"></i>');
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (PRADIPTA.Phone.Notifications.Timeout !== undefined || PRADIPTA.Phone.Notifications.Timeout !== null) {
                    clearTimeout(PRADIPTA.Phone.Notifications.Timeout);
                }
                PRADIPTA.Phone.Notifications.Timeout = setTimeout(function(){
                    PRADIPTA.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!PRADIPTA.Phone.Data.IsOpen) {
                        PRADIPTA.Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    PRADIPTA.Phone.Notifications.Timeout = null;
                }, timeout);
            }
        }
    });
}

PRADIPTA.Phone.Functions.LoadPhoneData = function(data) {
    PRADIPTA.Phone.Data.PlayerData = data.PlayerData;
    PRADIPTA.Phone.Data.PlayerJob = data.PlayerJob;
    PRADIPTA.Phone.Data.MetaData = data.PhoneData.MetaData;
    PRADIPTA.Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
    PRADIPTA.Phone.Functions.LoadContacts(data.PhoneData.Contacts);
    PRADIPTA.Phone.Functions.SetupApplications(data);

    $("#player-id").html("<span>" + "ID: " + data.PlayerId + "</span>")
}

PRADIPTA.Phone.Functions.UpdateTime = function(data) {
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss

    $("#phone-time").html("<span>" + data.InGameTime.hour + ":" + data.InGameTime.minute + "</span>");
}

var NotificationTimeout = null;

PRADIPTA.Screen.Notification = function(title, content, icon, timeout, color) {
    $.post('https://pradipta-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (color != null && color != undefined) {
                $(".screen-notifications-container").css({"background-color":color});
            }
            $(".screen-notification-icon").html('<i class="'+icon+'"></i>');
            $(".screen-notification-title").text(title);
            $(".screen-notification-content").text(content);
            $(".screen-notifications-container").css({'display':'block'}).animate({
                right: 5+"vh",
            }, 200);

            if (NotificationTimeout != null) {
                clearTimeout(NotificationTimeout);
            }

            NotificationTimeout = setTimeout(function(){
                $(".screen-notifications-container").animate({
                    right: -35+"vh",
                }, 200, function(){
                    $(".screen-notifications-container").css({'display':'none'});
                });
                NotificationTimeout = null;
            }, timeout);
        }
    });
}

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
        if (up){
            $('#popup').fadeOut('slow');
            $('.popupclass').fadeOut('slow');
            $('.popupclass').html("");
            up = false
        } else {
            PRADIPTA.Phone.Functions.Close();
            break;
        }
    }
});

PRADIPTA.Screen.popUp = function(source){
    if(!up){
        $('#popup').fadeIn('slow');
        $('.popupclass').fadeIn('slow');
        $('<img  src='+source+' style = "width:100%; height: 100%;">').appendTo('.popupclass')
        up = true
    }
}

PRADIPTA.Screen.popDown = function(){
    if(up){
        $('#popup').fadeOut('slow');
        $('.popupclass').fadeOut('slow');
        $('.popupclass').html("");
        up = false
    }
}

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                PRADIPTA.Phone.Functions.Open(event.data);
                PRADIPTA.Phone.Functions.SetupAppWarnings(event.data.AppData);
                PRADIPTA.Phone.Functions.SetupCurrentCall(event.data.CallData);
                PRADIPTA.Phone.Data.IsOpen = true;
                PRADIPTA.Phone.Data.PlayerData = event.data.PlayerData;
                break;
            case "LoadPhoneData":
                PRADIPTA.Phone.Functions.LoadPhoneData(event.data);
                break;
            case "UpdateTime":
                PRADIPTA.Phone.Functions.UpdateTime(event.data);
                break;
            case "Notification":
                PRADIPTA.Screen.Notification(event.data.NotifyData.title, event.data.NotifyData.content, event.data.NotifyData.icon, event.data.NotifyData.timeout, event.data.NotifyData.color);
                break;
            case "PhoneNotification":
                PRADIPTA.Phone.Notifications.Add(event.data.PhoneNotify.icon, event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout);
                break;
            case "RefreshAppAlerts":
                PRADIPTA.Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
            case "UpdateMentionedTweets":
                PRADIPTA.Phone.Notifications.LoadMentionedTweets(event.data.Tweets);
                break;
            case "UpdateBank":
                $(".bank-app-account-balance").html("&#36; "+event.data.NewBalance);
                $(".bank-app-account-balance").data('balance', event.data.NewBalance);
                break;
            case "UpdateChat":
                if (PRADIPTA.Phone.Data.currentApplication == "whatsapp") {
                    if (OpenedChatData.number !== null && OpenedChatData.number == event.data.chatNumber) {
                        PRADIPTA.Phone.Functions.SetupChatMessages(event.data.chatData);
                    } else {
                        PRADIPTA.Phone.Functions.LoadWhatsappChats(event.data.Chats);
                    }
                }
                break;
            case "UpdateHashtags":
                PRADIPTA.Phone.Notifications.LoadHashtags(event.data.Hashtags);
                break;
            case "RefreshWhatsappAlerts":
                PRADIPTA.Phone.Functions.ReloadWhatsappAlerts(event.data.Chats);
                break;
            case "CancelOutgoingCall":
                $.post('https://pradipta-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        CancelOutgoingCall();
                    }
                });
                break;
            case "IncomingCallAlert":
                $.post('https://pradipta-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
                    }
                });
                break;
            case "SetupHomeCall":
                PRADIPTA.Phone.Functions.SetupCurrentCall(event.data.CallData);
                break;
            case "AnswerCall":
                PRADIPTA.Phone.Functions.AnswerCall(event.data.CallData);
                break;
            case "UpdateCallTime":
                var CallTime = event.data.Time;
                var date = new Date(null);
                date.setSeconds(CallTime);
                var timeString = date.toISOString().substr(11, 8);
                if (!PRADIPTA.Phone.Data.IsOpen) {
                    if ($(".call-notifications").css("right") !== "52.1px") {
                        $(".call-notifications").css({"display":"block"});
                        $(".call-notifications").animate({right: 5+"vh"});
                    }
                    $(".call-notifications-title").html("In conversation ("+timeString+")");
                    $(".call-notifications-content").html("Calling with "+event.data.Name);
                    $(".call-notifications").removeClass('call-notifications-shake');
                } else {
                    $(".call-notifications").animate({
                        right: -35+"vh"
                    }, 400, function(){
                        $(".call-notifications").css({"display":"none"});
                    });
                }
                $(".phone-call-ongoing-time").html(timeString);
                $(".phone-currentcall-title").html("In conversation ("+timeString+")");
                break;
            case "CancelOngoingCall":
                $(".call-notifications").animate({right: -35+"vh"}, function(){
                    $(".call-notifications").css({"display":"none"});
                });
                PRADIPTA.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                setTimeout(function(){
                    PRADIPTA.Phone.Functions.ToggleApp("phone-call", "none");
                    $(".phone-application-container").css({"display":"none"});
                }, 400)
                PRADIPTA.Phone.Functions.HeaderTextColor("white", 300);

                PRADIPTA.Phone.Data.CallActive = false;
                PRADIPTA.Phone.Data.currentApplication = null;
                break;
            case "RefreshContacts":
                PRADIPTA.Phone.Functions.LoadContacts(event.data.Contacts);
                break;
            case "UpdateMails":
                PRADIPTA.Phone.Functions.SetupMails(event.data.Mails);
                break;
            case "RefreshAdverts":
                if (PRADIPTA.Phone.Data.currentApplication == "advert") {
                    PRADIPTA.Phone.Functions.RefreshAdverts(event.data.Adverts);
                }
                break;
            case "UpdateTweets":
                if (PRADIPTA.Phone.Data.currentApplication == "twitter") {
                    PRADIPTA.Phone.Notifications.LoadTweets(event.data.Tweets);
                }
                break;
            case "AddPoliceAlert":
                AddPoliceAlert(event.data)
                break;
            case "UpdateApplications":
                PRADIPTA.Phone.Data.PlayerJob = event.data.JobData;
                PRADIPTA.Phone.Functions.SetupApplications(event.data);
                break;
            case "UpdateTransactions":
                RefreshCryptoTransactions(event.data);
                break;
            case "UpdateRacingApp":
                $.post('https://pradipta-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                    SetupRaces(Races);
                });
                break;
            case "RefreshAlerts":
                PRADIPTA.Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
        }
    })
});