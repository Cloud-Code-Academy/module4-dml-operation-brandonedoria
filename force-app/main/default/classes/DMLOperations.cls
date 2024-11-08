/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Brandon Edoria
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        Account newAccount = new Account(Name = 'Vandelay Industries');

        insert newAccount;      // Inserting the account gets the Account Id
        return newAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        Account newAccount = new Account(Name = name, Industry = industry);

        insert newAccount;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        Contact newContact = new Contact(FirstName = 'George', LastName = 'Costanza', AccountId = accountId);

        insert newContact;
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        Contact retrieveContact = [SELECT Id FROM Contact WHERE Id = :contactId];   // PROVIDED

        retrieveContact.LastName = newLastName;

        update retrieveContact;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        Opportunity newOpportunity = [SELECT Id FROM Opportunity WHERE Id = :oppId];    // PROVIDED

        newOpportunity.StageName = newStage;

        update newOpportunity;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        Account retrieveAccount = [SELECT Id FROM Account WHERE Id = :accountId];   //  PROVIDED

        retrieveAccount.Name = newName;
        retrieveAccount.Industry = newIndustry;

        update retrieveAccount;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;
        }
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {

        List<Account> accountList = [SELECT Id FROM Account WHERE Id = :accountName];  // create a list of accounts where the account name matches input variable
        Account accountMaybe;                                                          // initialize account in order to upsert/return later

        if (accountList.isEmpty()) {
            accountMaybe = new Account(Name = accountName);     // if there's no match, create an account
        } else {
            accountMaybe = accountList[0];                      // if there is a match, set it to the account variable initialized earlier
        }

        upsert accountMaybe;                                    // upsert account into org in order to get AccoundId for later

        Set<Opportunity> oppSet = new Set<Opportunity>();       // initialize set of opportunities to avoid duplicates
        List<Opportunity> oppList = new List<Opportunity>();    // initialize list of opportunities to upsert later

        for (String opp : oppNames) {                           // iteration loop
            Opportunity newOpp = new Opportunity();             // create new opportunity with every new name
            newOpp.Name = opp;                                  // update name
            newOpp.AccountId = accountMaybe.Id;                 // update account name to account created above
            newOpp.StageName = 'Prospecting';                   // update stage name
            newOpp.CloseDate = Date.today().addMonths(3);       // update close date to 3 months from now
            oppSet.add(newOpp);                                 // add each newly created opportunity to the list of opportunities
        }
        oppList.addAll(oppSet);                                 // convert set to list to be able to upsert
        upsert oppList;                                         // upsert list of opportunities
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		List<Account> accountList = [SELECT Id FROM Account WHERE Name = :accountName];     // PROVIDED create a list of accounts where the account name matches the input variable
        Account accountMaybe;                                                               // initialize account in order to upsert/return later

        if (!accountList.isEmpty()) {
            accountMaybe = accountList[0];                                                  // if there is a match, set it to the account variable initialized earlier
            accountMaybe.Description = 'Updated Account';                                   // & update description
        } else {
            accountMaybe = new Account(Name = accountName, Description = 'New Account');    // if there's no match, create an account & update name/description
        }
        upsert accountMaybe;                                                                // upsert account depending
        return accountMaybe;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        for (Contact con : contactsToUpsert) {                      // iteration loop
            Account newEdition = upsertAccount(con.LastName);       // use method from previous question to create an account if it doesn't exist or get account if it does. understand it is NOT best practice to put queries and DMLs inside of loops
            con.AccountId = newEdition.Id;                          // associate each contact with account
        }
        upsert contactsToUpsert;
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> leadList = new List<Lead>();

        for (String leadName : leadNames) {
            Lead newLead = new Lead(LastName = leadName, Company = 'Vandalay Industries');
            leadList.add(newLead);
        }
        insert leadList;
        delete leadList;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> caseList = new List<Case>();

        for (Integer i = 0; i < numOfCases; i++) {
            Case newCase = new Case(AccountId = accountId);
            caseList.add(newCase);
        }
        insert caseList;
        delete caseList;
    }
}