<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

<html>
    <head>
         <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
         <meta name="layout" content="grailsflow" />
         <g:render plugin="grailsflow" template="/commons/global"/>
         <gf:messageBundle bundle="grailsflow.common" var="common"/>
         <gf:messageBundle bundle="grailsflow.processDetails" var="processDetails"/>

         <r:require modules="grailsflowJgplot"/>

         <r:script>
             var data = evalJson('${processTypeProtocol}')

             if (data && data.length > 0) {
               var xCoordinates = []
               var lines  = []
               var series = []

               for (var i=0; i< data.length; i++){
                 var line = []
                 var yCoordinates = []
                 var process = data[i]["processId"]
                 var protocolGroups = data[i]["protocolGroups"]
                 for (var group in protocolGroups){
                   var nodes = protocolGroups[group]
                   if (i == 0) xCoordinates.push(group)
                   var totalExecutionTime = 0
                   for (var j=0; j< nodes.length; j++){
                     totalExecutionTime = totalExecutionTime + parseInt(nodes[j]["executionTime"])
                   }
                   yCoordinates[group] = totalExecutionTime
                 }

                 for (var j=0; j< xCoordinates.length; j++) {
                   var protocolGroup = xCoordinates[j]
                   line.push([protocolGroup, yCoordinates[protocolGroup]])
                 }

                 series.push({color: get_random_color(), label: "${processDetails['grailsflow.label.processID']} = "+process})
                 lines.push(line)
               }

               jQuery.noConflict();

               jQuery(document).ready(function($){
                 jQuery.jqplot.config.enablePlugins = true;
                 jQuery.jqplot("graphic", lines,
                           { title: '',
                             axes: {
                                 yaxis: { label: "${processDetails['grailsflow.label.executionTime']}",
                                          labelOptions: {
                                               enableFontSupport: true,
                                               fontFamily: 'Tahoma',
                                               fontSize: '13px',
                                               textColor: '#002276'
                                           },  autoscale:true, min: 0 },
                                 xaxis: { label: "${processDetails['grailsflow.label.protocolGroups']}",
                                          labelOptions: {
                                               enableFontSupport: true,
                                               fontFamily: 'Tahoma',
                                               fontSize: '13px',
                                               textColor: '#002276'
                                           },
                                 renderer: jQuery.jqplot.CategoryAxisRenderer }
                             },
                             series: series,
                             legend: {
                                 renderer: jQuery.jqplot.EnhancedLegendRenderer,
                                 show: true,
                                 location:'ne',
                                 placement: 'outsideGrid',
                                 shrinkGrid: true,
                             }

                           }
                          );

               });

             }

             function evalJson(json) {
               try {
                 return eval("(" + json + ")");
               } catch (e) {  return null;}
             }

             function get_random_color() {
               var color = Math.floor(Math.random() * 16777216).toString(16);
               return '#000000'.slice(0, -color.length) + color;
             }

         </r:script>
         <style>
            table.jqplot-table-legend {
                display: block;
                height: 300px;
                overflow-y: scroll;
            }
         </style>
         <title>${processDetails['grailsflow.title.analyseResponseTime']}</title>
    </head>
    <body>
      <h1>${processDetails['grailsflow.label.analyseResponseTime']}</h1>

      <g:form class="form-horizontal" controller="${params['controller']}" method="GET">
        <div class="row">
          <div class="col-md-6 col-xs-6 col-lg-6">
            <div class="form-group">
              <label class="col-sm-4 col-xs-4 col-md-4 col-lg-4  control-label" for="type">
                ${processDetails['grailsflow.label.processType']}
              </label>
              <div class="col-sm-8 col-md-8 col-lg-8 col-xs-8">
                  <g:select from="${processClasses}" name='type' id="type"
                            optionKey="${{it.processType}}" optionValue="${{gf.translatedValue(translations: it.label, default: it.processType)}}"
                            noSelection="['':'']" value="${params.type}"></g:select>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 col-xs-4 col-md-4 col-lg-4  control-label">
                ${processDetails['grailsflow.label.sortBy']}
              </label>
              <div class="col-sm-8 col-md-8 col-lg-8 col-xs-8">
                <g:select name='sortBy' value="${params.sortBy}" noSelection="['':'']"
                            from="${[ AnalyseController.SORT_BY_NODE, AnalyseController.SORT_BY_MIN_TIME,
                                    AnalyseController.SORT_BY_MAX_TIME, AnalyseController.SORT_BY_AVERAGE_TIME,
                                    AnalyseController.SORT_BY_INTERACTIVE_NODE, AnalyseController.SORT_BY_NONINTERACTIVE_NODE]}"
                            optionValue="${{processDetails['grailsflow.label.'+it] ?: ''}}" />
              </div>
            </div>
            <div class="form-group">
              <div class="col-sm-12 col-md-12 col-lg-12 col-xs-12">
                <g:actionSubmit action="searchNodesInfo" value="${common['grailsflow.command.search']}" class="btn btn-primary"/>
              </div>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-md-12 col-xs-12 col-lg-12">
            <h4>${processDetails['grailsflow.label.protocolingNodes']}</h4>
            <g:if test="${processTypeProtocol}">
              <div class="jqplot-target" id="graphic" style="width:800px; height: 300px; position: relative;"></div>
            </g:if>
            <g:else>${processDetails['grailsflow.label.noProtocolGroups']}</g:else>

          </div>
        </div>

        <div class="row">
          <div class="col-md-12 col-xs-12 col-lg-12">
            <h4>${params.type?.encodeAsHTML()} &nbsp;${processDetails['grailsflow.label.processList']}</h4>
            <table class="table table-bordered">
                <thead>
                  <tr><th>${processDetails['grailsflow.label.nodeID']}</th>
                      <th>${processDetails['grailsflow.label.quantity']}</th>
                      <th>${processDetails['grailsflow.label.minTime']}</th>
                      <th>${processDetails['grailsflow.label.maxTime']}</th>
                      <th>${processDetails['grailsflow.label.averageTime']}</th>
                      <th>${processDetails['grailsflow.label.type']}</th>
                  </tr>
                </thead>
                <tbody>
                  <g:each in="${processNodes}" var="nodeInfo">
                    <tr>
                      <td><gf:translatedValue translations="${nodeInfo?.label}" default="${nodeInfo?.nodeID}"/></td>
                      <td>${nodeInfo?.quantity}</td>
                      <td><gf:displayDouble value="${nodeInfo?.minTime/1000}"/>&nbsp;(${processDetails['grailsflow.label.processID']}=${nodeInfo?.processMinTime})</td>
                      <td><gf:displayDouble value="${nodeInfo?.maxTime/1000}"/>&nbsp;(${processDetails['grailsflow.label.processID']}=${nodeInfo?.processMaxTime})</td>
                      <td><gf:displayDouble value="${nodeInfo?.averageTime/1000}"/></td>
                      <td>${nodeInfo?.type}</td>
                    </tr>
                  </g:each>
                </tbody>
            </table>
          </div>
        </div>
      </g:form>
    </body>
</html>
