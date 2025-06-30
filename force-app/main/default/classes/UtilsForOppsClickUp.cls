public class UtilsForOppsClickUp {
    List<Opportunity> oppList = new List<Opportunity>();
    String WorkSpaceName;
    String SpaceName;
    String ListName;
    public UtilsForOppsClickUp(List<Opportunity> opp){
        this.oppList = opp;
    }
    public UtilsForOppsClickUp(List<Opportunity> opp, String WorkSpace, String SpaceName, String ListName){
        this.oppList = opp;
        this.WorkSpaceName = WorkSpace;
        this.SpaceName = SpaceName;
        this.ListName = ListName;
    }
    public HttpResponse resGenerator(String prefix, String key, String postfix){
        Http hp = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ClickUpAPI/' + prefix + key + postfix);
        req.setMethod('GET');
        HttpResponse res = hp.send(req);
        return res;
    }
    public String idGetter(HttpResponse res, String objectKey, String idKey, String nameToMatch){
        Map<String, Object> mp = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> items = (List<Object>) mp.get(objectKey);

        for(Object obj : items){
            Map<String, Object> entry = (Map<String, Object>) obj;
            if(((String)entry.get('name')) == nameToMatch){
                return (String) entry.get(idKey);
            }
        }
        return null; 
    }

    public void mainGenerator(){
        if (WorkSpaceName == null) WorkSpaceName = 'CRM Testing Workspace';
        if (SpaceName == null) SpaceName = 'Team Space';
        if (ListName == null) ListName = 'Salesforce Tasks';
        HttpResponse r1 = resGenerator('team', '', '');
        if (r1.getStatusCode() != 200){
            System.debug('Failed to retrieve team ID');
            return;
        }
        String teamId = idGetter(r1, 'teams', 'id', WorkSpaceName);
        if (teamId == null){
            System.debug('Team ID not found for workspace: ' + WorkSpaceName);
            return;
        }
        HttpResponse r2 = resGenerator('team/', teamId, '/space');
        if (r2.getStatusCode() != 200){
            System.debug('Failed to retrieve space ID');
            return;
        }
        String spaceId = idGetter(r2, 'spaces', 'id', SpaceName);
        if (spaceId == null){
            System.debug('Space ID not found for space: ' + SpaceName);
            return;
        }
        HttpResponse r3 = resGenerator('space/', spaceId, '/list');
        if (r3.getStatusCode() != 200){
            System.debug('Failed to retrieve list ID');
            return;
        }
        String listId = idGetter(r3, 'lists', 'id', ListName);
        if (listId == null){
            System.debug('List ID not found for list: ' + ListName);
            return;
        }
        for(Opportunity o : oppList){
            Map<String, Object> payload = new Map<String, Object>{
                'name' => 'Follow up on failed opportunity: ' + o.Name,
                'description' => 'Please follow up with the opportunity owner. Status of Opportunity ' + o.Name + ' needs review.'
            };
            Http hp = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:ClickUpAPI/list/' + listId + '/task');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(payload));

            HttpResponse res = hp.send(req);
            System.debug('Task creation response: ' + res.getBody());
        }
    }
}