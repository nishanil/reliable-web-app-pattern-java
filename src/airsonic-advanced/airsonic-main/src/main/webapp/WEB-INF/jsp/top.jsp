<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>

<html><head>
    <%@ include file="head.jsp" %>
    <%@ include file="jquery.jsp" %>

    <script type="text/javascript">
        var previousQuery = "";
        var instantSearchTimeout;
        var showSideBar = ${model.showSideBar};

        function init() {
            top.StompClient.subscribe("top.jsp", {
                "/user/queue/settings/sidebar": function(msg) {
                    toggleLeftFrameCallback(JSON.parse(msg.body));
                }
            });

            top.StompClient.onConnect.push(function() {
                setConnectedImage();
            });

            top.StompClient.onDisconnect.push(function() {
                setDisconnectedImage();
            });

            top.StompClient.onConnecting.push(function() {
                setConnectingImage();
            });

            // in case this frame instantiates too late
            if (top.StompClient.state == 'connected') {
                setConnectedImage();
            }
        }

        function setConnectedImage() {
            $("#connectionStatus img").attr("src", "<spring:theme code='connectedImage'/>");
            $("#connectionStatus div").text("<fmt:message key='top.connected' />");
        }

        function setDisconnectedImage() {
            $("#connectionStatus img").attr("src", "<spring:theme code='disconnectedImage'/>");
            $("#connectionStatus div").text("<fmt:message key='top.disconnected' />");
        }

        function setConnectingImage() {
            $("#connectionStatus img").attr("src", "<spring:theme code='connectingImage'/>");
            $("#connectionStatus div").text("<fmt:message key='top.connecting' />");
        }

        function toggleLeftFrameCallback(show) {
            if (showSideBar != show) {
                if (show) {
                    doShowLeftFrame();
                } else {
                    doHideLeftFrame();
                }
            }
        }

        function triggerInstantSearch() {
            if (instantSearchTimeout) {
                window.clearTimeout(instantSearchTimeout);
            }
            instantSearchTimeout = window.setTimeout(executeInstantSearch, 300);
        }

        function executeInstantSearch() {
            var query = $("#query").val().trim();
            if (query.length > 1 && query != previousQuery) {
                previousQuery = query;
                document.searchForm.submit();
            }
        }

        function showLeftFrame() {
            doShowLeftFrame();
            top.StompClient.send("/app/settings/sidebar", true);
        }

        function doShowLeftFrame() {
            $("div.left-nav-container", window.parent.document).show('slide', {direction:"left"}, 100, function() {
                $("#show-left-frame").hide();
                $("#hide-left-frame").show();
                showSideBar = true;
            });
        }

        function hideLeftFrame() {
            doHideLeftFrame();
            top.StompClient.send("/app/settings/sidebar", false);
        }

        function doHideLeftFrame() {
            $("div.left-nav-container", window.parent.document).hide('slide', {direction:"left"}, 100, function() {
                $("#hide-left-frame").hide();
                $("#show-left-frame").show();
                showSideBar = false;
            });
        }
        
        function toggleConnectionStatus() {
            setConnectingImage();
            if (top.StompClient.state == 'connected') {
                top.StompClient.disconnect();
            } else if (top.StompClient.state == 'dc') {
                top.StompClient.connect();
            }
        }

        function airsonicLogout() {
            $("#logoutForm")[0].submit();
        }
    </script>
</head>

<body class="bgcolor2 topframe" style="margin:0.4em 1em 0 1em;" onload="init()">

<span id="dummy-animation-target" style="max-width:0;display: none"></span>

<fmt:message key="top.home" var="home"/>
<fmt:message key="top.now_playing" var="nowPlaying"/>
<fmt:message key="top.starred" var="starred"/>
<fmt:message key="left.playlists" var="playlists"/>
<fmt:message key="top.settings" var="settings"/>
<fmt:message key="top.status" var="status" />
<fmt:message key="top.bookmarks" var="bookmarks"/>
<fmt:message key="top.more" var="more"/>
<fmt:message key="top.help" var="help"/>
<fmt:message key="top.search" var="search"/>

<table style="margin:0;padding-top:5px">
    <tr>
        <td style="padding-right:4.5em;">
            <img id="show-left-frame" src="<spring:theme code='sidebarImage'/>" onclick="showLeftFrame()" alt="" style="display:${model.showSideBar ? 'none' : 'inline'};cursor:pointer">
            <img id="hide-left-frame" src="<spring:theme code='sidebarImage'/>" onclick="hideLeftFrame()" alt="" style="display:${model.showSideBar ? 'inline' : 'none'};cursor:pointer">
        </td>
        <td style="min-width:3em;padding-right:1em;text-align: center">
            <a href="home.view?" target="main"><img src="<spring:theme code='homeImage'/>" title="${home}" alt="${home}"></a>
            <div class="topHeader"><a href="home.view?" target="main">${home}</a></div>
        </td>
        <c:if test="false">
        <td style="min-width:3em;padding-right:1em;text-align: center">
            <a href="nowPlaying.view?" target="main"><img src="<spring:theme code='nowPlayingImage'/>" title="${nowPlaying}" alt="${nowPlaying}"></a>
            <div class="topHeader"><a href="nowPlaying.view?" target="main">${nowPlaying}</a></div>
        </td>
        </c:if>
        <td style="min-width:3em;padding-right:1em;text-align: center">
            <a href="starred.view?" target="main"><img src="<spring:theme code='starredImage'/>" title="${starred}" alt="${starred}"></a>
            <div class="topHeader"><a href="starred.view?" target="main">${starred}</a></div>
        </td>
        <c:if test="${model.user.settingsRole}">
        <td style="min-width:3em;padding-right:1em;text-align: center">
            <a href="playlists.view?" target="main"><img src="<spring:theme code='playlistImage'/>" title="${playlists}" alt="${playlists}"></a>
            <div class="topHeader"><a href="playlists.view?" target="main">${playlists}</a></div>
        </td>
        </c:if>
        <!-- Proseware
        <td style="min-width:4em;padding-right:1em;text-align: center">
            <a href="bookmarks.view?" target="main"><img src="<spring:theme code='bookmarkImage'/>" title="${bookmarks}" alt="${bookmarks}"></a>
            <div class="topHeader"><a href="bookmarks.view?" target="main">${bookmarks}</a></div>
        </td>
        -->
        <c:if test="${model.user.settingsRole}">
            <td style="min-width:3em;padding-right:1em;text-align: center">
                <a href="settings.view?" target="main"><img src="<spring:theme code='settingsImage'/>" title="${settings}" alt="${settings}"></a>
                <div class="topHeader"><a href="settings.view?" target="main">${settings}</a></div>
            </td>
        </c:if>
        <c:if test="${model.user.settingsRole}">
        <td style="min-width:3em;padding-right:1em;text-align: center">
            <a href="status.view?" target="main"><img src="<spring:theme code='statusImage'/>" title="${status}" alt="${status}"></a>
            <div class="topHeader"><a href="status.view?" target="main">${status}</a></div>
        </td>
        </c:if>
        <c:if test="${model.user.settingsRole}">
        <td style="min-width:3em;padding-right:1em;text-align: center">
            <a href="more.view?" target="main"><img src="<spring:theme code='moreImage'/>" title="${more}" alt="${more}"></a>
            <div class="topHeader"><a href="more.view?" target="main">${more}</a></div>
        </td>
        </c:if>
        <!-- Proseware
        <td style="min-width:3em;padding-right:1em;text-align: center">
            <a href="help.view?" target="main"><img src="<spring:theme code='helpImage'/>" title="${help}" alt="${help}"></a>
            <div class="topHeader"><a href="help.view?" target="main">${help}</a></div>
        </td>
        -->

        <td style="padding-left:1em">
            <form method="post" action="search.view" target="main" name="searchForm">
                <td><input required type="text" name="query" id="query" size="28" placeholder="${search}" onclick="select();"
                           onkeyup="triggerInstantSearch();"></td>
                <td><a href="javascript:document.searchForm.submit()"><img src="<spring:theme code='searchImage'/>" alt="${search}" title="${search}"></a></td>
            </form>
        </td>

        <td style="padding-left:15pt;padding-right:5pt;vertical-align: middle;width: 100%;text-align: center">
            <div>
            <c:if test="${model.user.settingsRole}">
              <a href="personalSettings.view" target="main">
            </c:if>
            <c:choose>
              <c:when test="${model.showAvatar}">
                <sub:url value="avatar.view" var="avatarUrl">
                  <sub:param name="username" value="${model.user.username}"/>
                </sub:url>
                <img src="${avatarUrl}" alt="User" width="30" height="30">
              </c:when>
              <c:otherwise>
                <img src="<spring:theme code='userImage'/>" alt="User" height="24">
              </c:otherwise>
            </c:choose>
            <c:if test="${model.user.settingsRole}">
              </a>
            </c:if>
              <div class="topHeader">
                <c:if test="${model.user.settingsRole}">
                  <a href="personalSettings.view" target="main">
                </c:if>
                  <c:out value="${model.user.username}" escapeXml="true"/>
                <c:if test="${model.user.settingsRole}">
                  </a>
                </c:if>
              </div>
            </div>
        </td>

        <c:if test="false">
        <td style="padding-left:15pt;padding-right:5pt;vertical-align: right;width: 100%;text-align: center">
            <a id="connectionStatus" href="javascript:void(0)" onclick="toggleConnectionStatus();">
                <img src="<spring:theme code='disconnectedImage'/>" alt="connect" height="24">
                <div class="detail">
                    <fmt:message key="top.disconnected"></fmt:message>
                </div>
            </a>
        </td>

        <td style="padding-left:15pt;padding-right:5pt;vertical-align: right;width: 100%;text-align: center">
            <a href="#" onclick="airsonicLogout();">
                <img src="<spring:theme code='logoutImage'/>" alt="logout" height="24">
                <div class="detail">
                    <fmt:message key="top.logout"></fmt:message>
                </div>
            </a>
        </td>
        </c:if>

    </tr></table>
    <form id="logoutForm" action="<c:url value='/logout'/>"  method="POST" style="display:none">
        <sec:csrfInput />
    </form>

</body></html>
