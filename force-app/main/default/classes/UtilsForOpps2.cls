public with sharing class UtilsForOpps2 {
    // made public for testing purposes only
    public Opportunity oppList;
    public String WorkSpaceName;
    public String SpaceName;
    public String ListName;

    public UtilsForOpps2(Opportunity opp, String WorkSpace, String SpaceName, String ListName){
        this.oppList = opp;
        this.WorkSpaceName = WorkSpace;
        this.SpaceName = SpaceName;
        this.ListName = ListName;
    }

    public HttpResponse resGenerator(String prefix, String key, String postfix){
        Http hp = new Http();
        HttpRequest req = new HttpRequest();
        String endpoint = 'callout:ClickUpAPI/' + prefix + key + postfix;
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        LogHelper.log('Calling endpoint: ' + endpoint);
        HttpResponse res = hp.send(req);
        LogHelper.log('Received response: ' + res.getBody());
        return res;
    }

    public String idGetter(HttpResponse res, String objectKey, String idKey, String nameToMatch){
        Map<String, Object> mp = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> items = (List<Object>) mp.get(objectKey);

        LogHelper.log('Looking for name: ' + nameToMatch + ' in key: ' + objectKey);
        for(Object obj : items){
            Map<String, Object> entry = (Map<String, Object>) obj;
            String foundName = (String) entry.get('name');
            if(foundName == nameToMatch){
                LogHelper.log('Matched name: ' + foundName + ', returning ID: ' + (String) entry.get(idKey));
                return (String) entry.get(idKey);
            } else {
                LogHelper.log('Name mismatch: expected ' + nameToMatch + ', found ' + foundName);
            }
        }
        LogHelper.log('No match found for name: ' + nameToMatch);
        return null; 
    }

    public HttpResponse postTask(String listId){
        Map<String, Object> payload = new Map<String, Object>{
            'name' => 'Follow up on failed opportunity: ' + oppList.Name,
            'description' => 'Please follow up with the opportunity owner. Status of Opportunity ' + oppList.Name + ' needs review.'
        };
        Http hp = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ClickUpAPI/list/' + listId + '/task');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(payload));
        HttpResponse res = hp.send(req);
        return res;
    }

    public void mainGenerator(){
        LogHelper.log('Starting task generation for Opportunity: ' + oppList.Name);

        if (WorkSpaceName == null) WorkSpaceName = 'CRM Testing Workspace';
        if (SpaceName == null) SpaceName = 'Team Space';
        if (ListName == null) ListName = 'Salesforce Tasks';

        HttpResponse r1 = resGenerator('team', '', '');
        if (r1.getStatusCode() != 200){
            return;
        }
        String teamId = idGetter(r1, 'teams', 'id', WorkSpaceName);
        if (teamId == null){
            return;
        }

        HttpResponse r2 = resGenerator('team/', teamId, '/space');
        if (r2.getStatusCode() != 200){
            return;
        }
        String spaceId = idGetter(r2, 'spaces', 'id', SpaceName);
        if (spaceId == null){
            return;
        }

        HttpResponse r3 = resGenerator('space/', spaceId, '/list');
        if (r3.getStatusCode() != 200){
            return;
        }
        String listId = idGetter(r3, 'lists', 'id', ListName);
        if (listId == null){
            return;
        }
        postTask(listId);
    }
}