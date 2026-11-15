using { hr } from '../db/schema';

@requires: 'authenticated-user'
service HRService {

  @restrict: [
    { grant: 'READ', to: 'Employee', where: 'userId = $user' },
    { grant: '*',    to: ['Manager', 'HRAdmin'] }
  ]
  entity Employees as projection on hr.Employees;

  @restrict: [
    { grant: ['READ', 'CREATE'], to: 'Employee', where: 'employee.userId = $user' },
    { grant: '*',                to: ['Manager', 'HRAdmin'] }
  ]
  entity LeaveRequests as projection on hr.LeaveRequests actions {
    @(requires: 'Manager')
    action approve();
    @(requires: 'Manager')
    action reject();
  };
}
