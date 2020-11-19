/**
     * That's a very slow method to get a standard profile Id without using profile.name
     * who depends on the user language, but using FullName instead.
     * Profiles available are Admin, SolutionManager, ReadOnly, Custom%3A Sales Profile, Custom%3A Marketing Profile,
     * Custom%3A Support Profile, MarketingProfile, ContractManager, Standard
     */
    public static String getStandardProfileId(String profileName){ 
        List<Profile> sfProfiles = [Select Id, CreatedDate from Profile where UserLicense.Name='Salesforce' order by CreatedDate];
        Set<Id> profileIds = new Set<Id>();
        DateTime orgBirth;
        for (Profile p : sfProfiles){
            if (orgBirth==null) orgBirth = p.CreatedDate;
            if (p.CreatedDate == orgBirth) profileIds.add(p.Id);
        }
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        while (profileIds.size()>0) {
            String condition =' where Id  in' + profileIds.toString()
                    				.replace('{', '(\'')
                    				.replace('}', '\')')
                    				.replace(', ', '\', \'');
            String query = EncodingUtil.urlEncode('Select Id, FullName from Profile ' + condition + ' limit 1', 'UTF-8')  ; 
            req.setEndpoint( URL.getOrgDomainUrl().toExternalForm() + '/services/data/v50.0/tooling/query/?q=' + query);
            HttpResponse res = h.send(req);
            List<Object> records = (List<Object>) (((Map<String, Object>) JSON.deserializeUntyped(res.getBody())).get('records'));
            Map<String, Object> record = (Map<String, Object>) records[0];
            if (record.get('FullName')==profileName) return (String)(record.get('Id'));
            else profileIds.remove((String) record.get('Id'));
        }
        return null;
    }
