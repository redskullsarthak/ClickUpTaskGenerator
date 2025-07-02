@isTest
global with sharing class ClickUpMockCallout  implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String endpoint = req.getEndpoint();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        if (endpoint.contains('/team')) {
            res.setBody('{"teams": [{"id": "team123", "name": "CRM Testing Workspace"}]}');
        } else if (endpoint.contains('/space')) {
            res.setBody('{"spaces": [{"id": "space123", "name": "Team Space"}]}');
        } else if (endpoint.contains('/list')) {
            if (req.getMethod() == 'GET') {
                res.setBody('{"lists": [{"id": "list123", "name": "Salesforce Tasks"}]}');
            } else if (req.getMethod() == 'POST') {
                res.setBody('{"id": "task123", "name": "Created Task"}');
            }
        }
        return res;
    }
}