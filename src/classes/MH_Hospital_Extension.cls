public with sharing class MH_Hospital_Extension {
    public String contractId { get; set; }
    public String wrapperId { get; set; }
    public String consoleLog { get; set; }
    public String selectedDoctorsIds { get; set; }
    public Boolean disableAllButtons { get; set; }

    public Hospital__c hospital {
        get;
        set;
    }
    public Contract__c multiHireContract {
        get {
            if (multiHireContract == null) {
                multiHireContract = new Contract__c();
            }
            return multiHireContract;
        }
        set;
    }
    public Doctor__c selectedDoctor {
        get {
            if (selectedDoctor == null) {
                selectedDoctor = new Doctor__c();
            }
            return selectedDoctor;
        }
        set;
    }
    public Doctor__c searchedDoctor {
        get {
            if (searchedDoctor == null) {
                searchedDoctor = new Doctor__c();
            }
            return searchedDoctor;
        }
        set;
    }

    public List<Contract__c> contracts { get; set; }
    public List<Doctor__c> searchedDoctors {
        get;
        set;
    }

    public List<Doctor__c> copySearchedDoctors;
    public List<MH_Hospital_Service.DoctorWrapper> doctorWrappers {
        get;
        set;
    }

    public MH_Hospital_Service.DoctorWrapper doctorWrapper {
        get {
            if (doctorWrapper == null) {
                doctorWrapper = new MH_Hospital_Service.DoctorWrapper(new Doctor__c(), hospital);
            }
            return doctorWrapper;
        }
        set;
    }

    public MH_Hospital_Extension(ApexPages.StandardController stdController) {
        this.consoleLog = 'działa';
        this.disableAllButtons = false;
        this.hospital = (Hospital__c) stdController.getRecord();
        this.doctorWrappers = new List<MH_Hospital_Service.DoctorWrapper>();
        this.contracts = [SELECT Date_Started__c, Expire_Date__c, Doctor_Full_Name__c, Name, Status__c FROM Contract__c WHERE Hospital__c = :hospital.Id];
    }

    public void dismiss() {
        System.debug('DISMIS SIE KLIKA');
        MH_Hospital_Service.dismiss(contractId, hospital);
        contracts = [SELECT Date_Started__c, Expire_Date__c, Doctor_Full_Name__c, Name, Status__c FROM Contract__c WHERE Hospital__c = :hospital.Id];
    }

    public void findSearchedDoctors() {
        searchedDoctors = MH_Hospital_Service.findDoctors(searchedDoctor);
        copySearchedDoctors = MH_Hospital_Service.findDoctors(searchedDoctor);
    }

    public void clearData() {
        searchedDoctor = new Doctor__c();
        if (searchedDoctors != null) {
            searchedDoctors.clear();
        }
    }

    public void removeSelectIfClicked() {
        selectedDoctorsIds += selectedDoctor.Id;
    }

    public void clearEverything() {
        selectedDoctorsIds = '';

        contracts = null;
        selectedDoctor = null;
        if (doctorWrappers != null) {
            doctorWrappers.clear();
        }
        doctorWrapper = new MH_Hospital_Service.DoctorWrapper(new Doctor__c(), hospital);
        clearData();
        selectedDoctor = new Doctor__c();

    }

    public void addDoctorToList() {
        doctorWrappers.add(new MH_Hospital_Service.DoctorWrapper(selectedDoctor, hospital));
        removeSelectIfClicked();
        selectedDoctor = new Doctor__c();
    }

    public void removeDoctorFromList() {
        selectedDoctorsIds = selectedDoctorsIds.remove(selectedDoctor.Id);
        for (Integer i = 0; i < doctorWrappers.size(); i++) {
            if (doctorWrappers.get(i).Id == selectedDoctor.Id) {
                doctorWrappers.remove(i);
            }
        }
    }

    public void enableButtons() {
        disableAllButtons = false;
    }
    public void disableButtons() {
        disableAllButtons = true;
    }

    public Boolean allSuccess {
        get {
            if (allSuccess == null) {
                allSuccess = true;
            }
            return allSuccess;
        }
        set;
    }
    public void hireDoctors() {
        doctorWrappers = MH_Contract_Service.hospitalAllContracts(doctorWrappers);
        this.contracts = [SELECT Date_Started__c, Expire_Date__c, Doctor_Full_Name__c, Name, Status__c FROM Contract__c WHERE Hospital__c = :hospital.Id];
    }

    public MH_Hospital_Service.DoctorWrapper getDoctorWrapperFromList(String id) {
        for (MH_Hospital_Service.DoctorWrapper doctorWrapper : doctorWrappers) {
            if (doctorWrapper.Id == id) {
                return doctorWrapper;
            }
        }
        return null;
    }

    public void copyDateForAllContracts() {
        Date dateStarted = getDoctorWrapperFromList(wrapperId).contract.Date_Started__c;
        Date dateEnded = getDoctorWrapperFromList(wrapperId).contract.Expire_Date__c;

        for (MH_Hospital_Service.DoctorWrapper wrapperDoctor : doctorWrappers) {
            if (wrapperDoctor.Status != 'Success') {
                wrapperDoctor.contract.Date_Started__c = dateStarted;
                wrapperDoctor.contract.Expire_Date__c = dateEnded;
            }
        }
    }
}