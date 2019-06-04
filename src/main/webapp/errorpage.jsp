<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>

<%@ page isErrorPage="true"%><!-- only true can access exception object -->
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title><%=pageContext.getErrorData().getStatusCode()%></title>
    <style type="text/css">
        * {
            font-family: Lato, Arial, sans-serif;
            font-size: 20px;
            color: #707070;
        }
        .button {
            display: inline-block;
            text-align: center;
            vertical-align: middle;
            padding: 12px 24px;
            border: 0px solid #000000;
            border-radius: 30px;
            background: #00d89e;
            background: -webkit-gradient(linear, left top, left bottom, from(#00d89e), to(#05aa89));
            background: -moz-linear-gradient(top, #00d89e, #05aa89);
            background: linear-gradient(to bottom, #00d89e, #05aa89);
            -webkit-box-shadow: #e0dddd 0px 3px 5px 0px;
            -moz-box-shadow: #e0dddd 0px 3px 5px 0px;
            box-shadow: #e0dddd 0px 3px 5px 0px;
            font: normal normal 20px Lato, Arial, sans-serif;
            color: #ffffff;
            text-decoration: none;
        }
        .button:hover,
        .button:focus {
            background: #00ffbe;
            background: -webkit-gradient(linear, left top, left bottom, from(#00ffbe), to(#06cca4));
            background: -moz-linear-gradient(top, #00ffbe, #06cca4);
            background: linear-gradient(to bottom, #00ffbe, #06cca4);
            color: #ffffff;
            text-decoration: none;
        }
        .button:active {
            background: #00825f;
            background: -webkit-gradient(linear, left top, left bottom, from(#00825f), to(#05aa89));
            background: -moz-linear-gradient(top, #00825f, #05aa89);
            background: linear-gradient(to bottom, #00825f, #05aa89);
        }
    </style>
</head>

<body style="background-color:#F5F5F5">
<span style="height:150px;text-align:center;display:block;">
        <img src="<%=request.getContextPath()%>/images/logo/logo.png" alt="KAI Innovations" width="125px" height="auto" style="vertical-align:middle;" />
        <span style="vertical-align:middle;font-size:45px;color:#909090;">Looks like something went wrong...</span>
    </span>
<br>
<br>
<div style="text-align:center;vertical-align:top;">
    <span style="color:#06AA88;font-size:45px;">Error Code: </span>
    <span style="color:#80808;font-size:45px;"><%=pageContext.getErrorData().getStatusCode()%></span>
    <br>
    <br>
    <br>
    <div>
        <span style="font-weight:bold;font-size:18px;">Call or email KAI Support to get this fixed!</span>
    </div>
    <br>
    <div>
        <span style="font-size:18px;">905.444.9166 (during business hours)</span>
        <br>
        <span style="font-size:18px;">support@kaiinnovations.com</span>
    </div>
    <br>
    <br>
    <p style="font-weight:lighter;font-size:16px">Want to show us the problem when you call? Click below to launch a remote session.</p>
    <a class="button" href="https://get.teamviewer.com/5gjkzuy">TEAMVIEWER</a>
</div>
</body>

</html>
