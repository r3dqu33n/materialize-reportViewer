<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Viewer.aspx.cs" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Reports Viewer</title>
    <link rel="stylesheet" href="~/Content/materialize.css" />
    <link rel="stylesheet" href="../Content/material-icons.css" />
    <style>
        .no-margin {
            margin: 0 !important;
        }

        nav, footer {
            padding-left: 10px;
        }

        @media only screen and (min-width: 601px) {
            .navbar-fixed {
                margin-bottom: -5px;
            }
        }

        footer.page-footer {
            position: fixed;
            width: 100%;
            bottom: 0;
            padding-top: 0px !important;
        }

        #rvMain_ctl09 td {
            padding: 0;
        }

        nav.small {
            height: 28px;
            line-height: 28px;
        }

            nav.small div a.breadcrumb {
                font-size: 13px !important;
            }

                nav.small div a.breadcrumb:before {
                    margin: 0 !important;
                }

        nav .nav-wrapper a.disabled {
            background-color: lightgray;
            opacity: 0.5;
            color: black;
        }

        .header-search-wrapper {
            margin: 10px auto 0 auto;
            width: 140px;
            height: 40px;
            display: inline-block;
            position: relative;
            padding-right: 10px;
        }

            .header-search-wrapper .btn {
                position: absolute;
                font-size: 24px;
                top: 3px;
                left: 4px;
                line-height: 24px !important;
                -webkit-transition: color 200ms ease;
                transition: color 200ms ease;
                padding: 0px 3px;
                height: 30px;
            }

                .header-search-wrapper .btn i {
                    height: 30px;
                    line-height: 30px;
                }

        input.header-search-input {
            display: block;
            padding: 8px 8px 8px 40px;
            width: calc(100% - 48px);
            background: rgba(255,255,255,0.3);
            height: 20px;
            -webkit-transition: all 200ms ease;
            transition: all 200ms ease;
            border: none;
            font-size: 16px;
            appearance: textfield;
            font-weight: 400;
            outline: none;
            border-radius: 3px;
        }
    </style>
</head>
<body>
    <div class="navbar-fixed">
        <nav class="blue" role="navigation">
            <div class="nav-wrapper">
                <a href="#!" class="brand-logo">Logo</a>

                <ul class="right hide-on-med-and-down">
                    <li><a href="javascript:void(0)" id="refresh" class="hide"><i class="mdi-action-cached"></i></a></li>
                    <li>
                        <a id="export" class="dropdown-button hide" href="#" data-activates="dropdown1">
                            <i class="mdi-action-open-in-browser left no-margin"></i>
                            <%--Export--%>
                            <i class="mdi-navigation-arrow-drop-down right no-margin"></i>
                        </a>
                        <ul id="dropdown1" class="dropdown-content">
                            <li><a href="javascript:void(0)" id="export_excel">Excel</a></li>
                            <li><a href="javascript:void(0)" id="export_pdf">PDF</a></li>
                            <li><a href="javascript:void(0)" id="export_word">Word</a></li>
                        </ul>
                    </li>
                </ul>
                <div class="header-search-wrapper hide-on-med-and-down right">
                    <a id="search" class="btn blue accent-3 disabled">
                        <i class="mdi-action-search"></i>
                    </a>
                    <input id="searchText" name="Search" class="header-search-input z-depth-2" placeholder="Search" type="text">
                    <a id="search_next" class="btn hide blue accent-2" style="left: 101px;">
                        <i class="mdi-image-navigate-next"></i>
                    </a>
                </div>
            </div>
        </nav>
    </div>
    <nav class="small indigo">
        <div class="nav-wrapper">
            <div class="col s12">
                <a href="javascript:void(0)" class="breadcrumb">Reports</a>
                <a href="javascript:void(0)" class="breadcrumb"><%=rvMain.LocalReport.DisplayName %></a>
            </div>
        </div>
    </nav>

    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="rptContainer" style="display: none">
            <rsweb:ReportViewer ID="rvMain" runat="server" PromptAreaCollapsed="false" ShowPromptAreaButton="true" Height="100%" Width="100%" ZoomMode="FullPage" EnableTheming="False" Font-Names="Roboto" Font-Size="9pt" WaitMessageFont-Names="Roboto" WaitMessageFont-Size="14pt" CssClass="viewer" ClientIDMode="Static">
            </rsweb:ReportViewer>
        </div>

    </form>
    <footer class="page-footer blue lighten-1">
        <div class="footer-copyright">
            <span>Copyright © 2016 <a class="grey-text text-lighten-4" href="#" target="_blank">dotOne</a> All rights reserved.</span>
        </div>
    </footer>

    <script src="../Scripts/jquery-2.2.3.js"></script>
    <script src="../Scripts/materialize.js"></script>
    <script>
        var objReport = function () {
            this.tlbInstance = null;
            var self = this;
            self.typeTbl = Microsoft.Reporting.WebFormsClient._Toolbar.prototype;

            //  hackish
            var prevInit = self.typeTbl.initialize;

            //  it's called when all the initialization is done.
            self.typeTbl.initialize = function () {
                self.tlbInstance = this;
                prevInit.call(this);
                //  set initial states.
                $("#refresh").toggleClass("hide", self.tlbInstance.m_refreshButton == null);
                $("#export").toggleClass("hide", self.tlbInstance.m_exportButton == null);
                $("#search").closest("div").toggleClass("hide", self.tlbInstance.m_findButton == null);

                if (self.tlbInstance.m_findTextBox != null) {
                    self.tlbInstance.m_findTextBox = $("#searchText")[0];

                    $("#searchText").keypress(function(e) {
                        if (e.keyCode == 10 || e.keyCode == 13) {
                            $("#search").click();
                            e.preventDefault();
                        }
                    });
                }

            }

            //  old function
            var fc_en_dsExport = self.typeTbl.EnableDisableExportButton;

            self.typeTbl.EnableDisableExportButton = function (forEnable) {
                //var self = this;
                $("#export").toggleClass("disabled", !forEnable);
                //  call original handler
                fc_en_dsExport.call(this, forEnable);
            }

            //  proxy disable function
            var fc_en_dsImage = self.typeTbl.EnableDisableImage;

            self.typeTbl.EnableDisableImage = function (ctrl, forEnable) {
                if (arguments[0] === this.m_refreshButton) {
                    $("#refresh").toggleClass("disabled", !forEnable);
                }
                //  call original handler
                fc_en_dsImage.call(this, ctrl, forEnable);
            }

            var fc_en_dsTextButton = self.typeTbl.EnableDisableTextButton;

            self.typeTbl.EnableDisableTextButton = function (ctrl, forEnable) {
                if (arguments[0] === this.m_findButton) {
                    $("#search").toggleClass("disabled", !forEnable);
                } else if (arguments[0] === this.m_findNextButton) {
                    $("#search_next").toggleClass("hide", !forEnable);

                }
                //  call original handler
                fc_en_dsTextButton.call(this, ctrl, forEnable);
            }
        };
        //  set proxy object
        objReport();

        $(function () {
            $(".dropdown-button").dropdown();

            $("#refresh").click(function () {
                if ($(this).hasClass("disabled")) return;
                $find('rvMain').refreshReport();
            });
            $("#search_next").click(function() {
                $find('rvMain').findNext();
            });
            $("#export_excel").click(function () { $find('rvMain').exportReport('EXCELOPENXML'); });
            $("#export_pdf").click(function () { $find('rvMain').exportReport('PDF'); });
            $("#export_word").click(function () { $find('rvMain').exportReport('WORDOPENXML'); });

            $("#search").click(function () {
                if ($(this).hasClass("disabled")) return;
                $find('rvMain').find($(this).siblings("input").val());
            });
            //  hide all things.
            //$("#rvMain_ctl05").closest("tr").hide().prevAll().hide();
            $(".rptContainer").show();
        });
    </script>
</body>

</html>
