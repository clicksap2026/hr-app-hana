namespace hr;

using { cuid, managed } from '@sap/cds/common';

// One person who works in the company
entity Employees : cuid, managed {
  firstName  : String(50) @mandatory;
  lastName   : String(50) @mandatory;
  email      : String(100);
  userId     : String(50);   // the login name, used for "my own rows"
  department : String(50);
  manager    : Association to Employees;
  leaves     : Association to many LeaveRequests on leaves.employee = $self;
}

// One request for time off
entity LeaveRequests : cuid, managed {
  employee  : Association to Employees @mandatory;
  startDate : Date @mandatory;
  endDate   : Date @mandatory;
  days      : Integer;
  reason    : String(200);
  status    : String(10) enum { New; Approved; Rejected } default 'New';
}
