<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${project?.name.encodeAsHTML()} | Project | Field Capture</title>
    <script type="text/javascript" src="${grailsApplication.config.google.maps.url}"></script>
    <r:script disposition="head">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        projectAjaxUpdateUrl:"${createLink(action:'ajaxUpdate', id:project.projectId)}",
        projectEditUrl:"${createLink(action:'edit', id:project.projectId)}",
        sitesDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSitesFromProject', id:project.projectId)}",
        siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSiteFromProject', id:project.projectId)}",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
        siteEditUrl: "${createLink(controller: 'site', action: 'edit')}",
        removeSiteUrl: "${createLink(controller: 'site', action: '')}",
        activityEditUrl: "${createLink(controller: 'activity', action: 'edit')}",
        activityEnterDataUrl: "${createLink(controller: 'activity', action: 'enterData')}",
        activityPrintUrl: "${createLink(controller: 'activity', action: 'print')}",
        activityCreateUrl: "${createLink(controller: 'activity', action: 'createPlan')}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        activityViewUrl: "${createLink(controller: 'activity', action: 'index')}",
        siteCreateUrl: "${createLink(controller: 'site', action: 'createForProject', params: [projectId:project.projectId])}",
        siteSelectUrl: "${createLink(controller: 'site', action: 'select', params:[projectId:project.projectId])}&returnTo=${createLink(controller: 'project', action: 'index', id: project.projectId)}",
        siteUploadUrl: "${createLink(controller: 'site', action: 'uploadShapeFile', params:[projectId:project.projectId])}&returnTo=${createLink(controller: 'project', action: 'index', id: project.projectId)}",
        starProjectUrl: "${createLink(controller: 'project', action: 'starProject')}",
        addUserRoleUrl: "${createLink(controller: 'user', action: 'addUserAsRoleToProject')}",
        removeUserWithRoleUrl: "${createLink(controller: 'user', action: 'removeUserWithRole')}",
        projectMembersUrl: "${createLink(controller: 'project', action: 'getMembersForProjectId')}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseUrl}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        organisationLinkBaseUrl: "${grailsApplication.config.collectory.baseURL + 'public/show/'}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project.projectId)}"
        },
        here = window.location.href;

    </r:script>

    <style type="text/css">
        .well-title {
            border-bottom: 1px solid lightgrey;
            font-weight: bold;
            padding-bottom:5px;
            margin-bottom:10px;
            font-size:larger;
        }
    </style>

    <!--[if gte IE 8]>
        <style>
           .thumbnail > img {
                max-width: 400px;
            }
            .thumbnail {
                max-width: 410px;
            }
        </style>
    <![endif]-->
    <r:require modules="gmap3,mapWithFeatures,knockout,datepicker,amplify,jqueryValidationEngine, projects, attachDocuments, wmd, sliderpro"/>
</head>
<body>

<g:render template="banner"/>
<div class="container-fluid">
    <div class="row-fluid">
        <div class="row-fluid">
            <div class="clearfix">
                <g:if test="${flash.errorMessage || flash.message}">
                    <div class="span5">
                        <div class="alert alert-error">
                            <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                            ${flash.errorMessage?:flash.message}
                        </div>
                    </div>
                </g:if>

            </div>
        </div>
    </div>
    <div class="row-fluid">
        <!-- content  -->
        <ul class="nav nav-pills">
            <li class="active">
                <a href="#about" data-toggle="pill">About</a>
            </li>
            <li><a href="#news" data-toggle="pill">News</a></li>
            <li><a href="#surveys" data-toggle="pill">Surveys</a></li>
            <li><a href="#locations" data-toggle="pill">Locations</a></li>
            <li><a href="#documents" data-toggle="pill">Documents</a></li>
            <li><a href="#admin" data-toggle="pill">Admin</a></li>
        </ul>
    </div>
    <div class="pill-content">
        <div class="pill-pane active" id="about">
            <g:render template="aboutCitizenScienceProject"/>
        </div>
        <div class="pill-pane" id="news">
            <div class="row-fluid">
                <span class="span6">
                    <div class="well">
                        <div class="well-title">News and events</div>
                        <div data-bind="html:newsAndEvents()?newsAndEvents.markdownToHtml():'Nothing at this time'"></div>

                    </div>
                </span>
                <span class="span6">
                    <div class="well">
                        <div class="well-title">Project stories</div>
                        <div data-bind="html:projectStories()?projectStories.markdownToHtml():'Nothing at this time'"></div>
                    </div>
                </span>
            </div>
        </div>
        <div class="pill-pane" id="surveys">
            <g:render template="/shared/activitiesList"
                      model="[activities:activities ?: [], sites:project.sites ?: [], showSites:true, wordForActivity:'survey']"/>
        </div>
        <div class="pill-pane" id="locations">
            <!-- ko stopBinding:true -->
            <g:render template="/site/sitesList" model="[wordForSite:'location']"/>
            <!-- /ko -->
        </div>
        <div class="pill-pane" id="documents">
            Documents
        </div>
        <div class="pill-pane" id="admin">
            <h4>Administrator actions</h4>
            <div class="row-fluid">
                <p><button class="btn btn-small admin-action" data-bind="click:editProject"><i class="icon-edit"></i> Edit</button> Edit the project details and content</p>
                <g:if test="${fc.userIsAlaOrFcAdmin()}"><p><button class="admin-action btn btn-small btn-danger" data-bind="click:deleteProject"><i class="icon-remove icon-white"></i> Delete</button> Delete this project. <strong>This cannot be undone</strong></p></g:if>
            </div>

            <h3>Project Access</h3>
            <g:render template="/admin/addPermissions" model="[addUserUrl:g.createLink(controller:'user', action:'addUserAsRoleToProject'), entityId:project.projectId]"/>
            <g:render template="/admin/permissionTable" model="[loadPermissionsUrl:g.createLink(controller:'project', action:'getMembersForProjectId', id:project.projectId), removeUserUrl:g.createLink(controller:'user', action:'removeUserWithRoleFromProject'), entityId:project.projectId, user:user]"/>


        </div>


    </div>

</div>
<r:script>
    $(function() {
        var organisations = <fc:modelAsJavascript model="${organisations?:[]}"/>;
        var project = <fc:modelAsJavascript model="${project}"/>;
        var projectViewModel = new ProjectViewModel(project, ${user?.isEditor?:false}, organisations);

        var ViewModel = function() {
            var self = this;
            $.extend(this, projectViewModel);

            self.editProject = function() {
                window.location.href = fcConfig.projectEditUrl;
            };
            self.deleteProject = function() {
                var message = "<span class='label label-important'>Important</span><p><b>This cannot be undone</b></p><p>Are you sure you want to delete this project?</p>";
                bootbox.confirm(message, function(result) {
                    if (result) {
                        console.log("not implemented!");
                    }
                });
            };

        }
        ko.applyBindings(new ViewModel());
        if (projectViewModel.mainImageUrl()) {
            $( '#carousel' ).sliderPro({
                width: '100%',
                height: 400,
                arrows: false, // at the moment we only support 1 image
                buttons: false,
                waitForLayers: true,
                fade: true,
                autoplay: false,
                autoScaleLayers: false,
                touchSwipe:false // at the moment we only support 1 image
            });
        }

        initialiseSites(project.sites);
    <g:if test="${isAdmin || fc.userIsAlaOrFcAdmin()}">
        populatePermissionsTable();
    </g:if>
    });
</r:script>
</body>
</html>