import cds from '@sap/cds'

export default class HRService extends cds.ApplicationService {
  init() {
    const { LeaveRequests } = this.entities

    // Check the dates and count the days before a request is saved
    this.before(['CREATE', 'UPDATE'], LeaveRequests, req => {
      const { startDate, endDate } = req.data
      if (startDate && endDate) {
        if (endDate < startDate) {
          return req.error(400, 'End date must be on or after the start date', 'endDate')
        }
        const oneDay = 24 * 60 * 60 * 1000
        req.data.days = Math.round((new Date(endDate) - new Date(startDate)) / oneDay) + 1
      }
    })

    // Approve and reject change the status of one request
    this.on('approve', LeaveRequests, async req => {
      const [{ ID }] = req.params
      await UPDATE(LeaveRequests, ID).with({ status: 'Approved' })
    })

    this.on('reject', LeaveRequests, async req => {
      const [{ ID }] = req.params
      await UPDATE(LeaveRequests, ID).with({ status: 'Rejected' })
    })

    return super.init()
  }
}
