public class ClickUpTask {
    @future(callout=true)
    public static void generateTasks(set<Id> caseIds) {
        List<Case> cs=[SELECT Id, CaseNumber, Subject FROM Case WHERE Id IN : caseIds];
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ClickUpAPI/team');
        req.setMethod('GET');
        HttpResponse firstRes = http.send(req);
        if (firstRes.getStatusCode() != 200) {
            System.debug('Failed to retrieve team ID');
            return;
        }

        Map<String, Object> teamResp = (Map<String, Object>) JSON.deserializeUntyped(firstRes.getBody());
        List<Object> teams = (List<Object>) teamResp.get('teams');
        String teamId;
        for (Object t : teams) {
            Map<String, Object> tm = (Map<String, Object>) t;
            if ((String) tm.get('name') == 'CRM Testing Workspace') {
                teamId = (String) tm.get('id');
                break;
            }
        }
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('callout:ClickUpAPI/team/' + teamId + '/space');
        req2.setMethod('GET');
        HttpResponse spaceRes = http.send(req2);
        if (spaceRes.getStatusCode() != 200) {
            System.debug('Failed to retrieve space ID');
            return;
        }

        Map<String, Object> spaceMap = (Map<String, Object>) JSON.deserializeUntyped(spaceRes.getBody());
        List<Object> spaces = (List<Object>) spaceMap.get('spaces');
        String spaceId;
        for (Object s : spaces) {
            Map<String, Object> sm = (Map<String, Object>) s;
            if ((String) sm.get('name') == 'Team Space') {
                spaceId = (String) sm.get('id');
                break;
            }
        }
        HttpRequest req3 = new HttpRequest();
        req3.setEndpoint('callout:ClickUpAPI/space/' + spaceId + '/list');
        req3.setMethod('GET');
        HttpResponse listRes = http.send(req3);
        if (listRes.getStatusCode() != 200) {
            System.debug('Failed to retrieve lists');
            return;
        }

        Map<String, Object> listMap = (Map<String, Object>) JSON.deserializeUntyped(listRes.getBody());
        List<Object> lists = (List<Object>) listMap.get('lists');
        String listId;

        if (lists.isEmpty()) {
            HttpRequest createListReq = new HttpRequest();
            createListReq.setEndpoint('callout:ClickUpAPI/space/' + spaceId + '/list');
            createListReq.setMethod('POST');
            createListReq.setHeader('Content-Type', 'application/json');
            createListReq.setBody(JSON.serialize(new Map<String, Object>{'name' => 'Salesforce Case Tasks'}));

            HttpResponse createListRes = http.send(createListReq);
            if (createListRes.getStatusCode() == 200 || createListRes.getStatusCode() == 201) {
                Map<String, Object> newListMap = (Map<String, Object>) JSON.deserializeUntyped(createListRes.getBody());
                listId = (String) newListMap.get('id');
            } else {
                System.debug('Failed to create folderless list');
                return;
            }
        } else {
            Map<String, Object> firstList = (Map<String, Object>) lists[0];
            listId = (String) firstList.get('id');
        }
        for (Case c : cs) {
            HttpRequest taskReq = new HttpRequest();
            taskReq.setEndpoint('callout:ClickUpAPI/list/' + listId + '/task');
            taskReq.setMethod('POST');
            taskReq.setHeader('Content-Type', 'application/json');
            taskReq.setBody(JSON.serialize(new Map<String, Object> {'name' => 'Case: ' + c.CaseNumber,'description' => c.Subject != null ? c.Subject : 'Salesforce Case',
               'status' => 'to do'
               
            }));
            HttpResponse taskRes = http.send(taskReq);
            System.debug('Task Response: ' + taskRes.getBody());
        }
    }
}