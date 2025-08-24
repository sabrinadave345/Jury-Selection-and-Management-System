;; Case Management Contract
;; Handles case creation, assignment, and tracking

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-INVALID-CASE (err u301))
(define-constant ERR-CASE-NOT-FOUND (err u302))
(define-constant ERR-INVALID-STATUS (err u303))
(define-constant ERR-JURY-NOT-ASSIGNED (err u304))

;; Data Variables
(define-data-var next-case-id uint u1)

;; Data Maps
(define-map cases
  { case-id: uint }
  {
    case-number: (string-ascii 50),
    case-type: (string-ascii 50),
    court-room: (string-ascii 20),
    judge: (string-ascii 100),
    plaintiff: (string-ascii 100),
    defendant: (string-ascii 100),
    created-at: uint,
    scheduled-start: uint,
    estimated-duration: uint,
    required-jury-size: uint,
    status: (string-ascii 20),
    priority: uint,
    description: (string-ascii 500)
  }
)

(define-map case-assignments
  { case-id: uint }
  {
    selection-id: uint,
    assigned-at: uint,
    jury-confirmed: bool,
    trial-started: bool,
    verdict-reached: bool,
    completed-at: (optional uint)
  }
)

(define-map case-documents
  { case-id: uint, document-id: uint }
  {
    document-type: (string-ascii 50),
    title: (string-ascii 200),
    hash: (string-ascii 64),
    uploaded-at: uint,
    access-level: (string-ascii 20)
  }
)

(define-map case-timeline
  { case-id: uint, event-id: uint }
  {
    event-type: (string-ascii 50),
    description: (string-ascii 200),
    occurred-at: uint,
    recorded-by: principal
  }
)

;; Public Functions

;; Create a new case
(define-public (create-case
  (case-number (string-ascii 50))
  (case-type (string-ascii 50))
  (court-room (string-ascii 20))
  (judge (string-ascii 100))
  (plaintiff (string-ascii 100))
  (defendant (string-ascii 100))
  (scheduled-start uint)
  (estimated-duration uint)
  (required-jury-size uint)
  (priority uint)
  (description (string-ascii 500)))
  (let
    (
      (case-id (var-get next-case-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (and (> required-jury-size u0) (< required-jury-size u25)) ERR-INVALID-CASE)
    (asserts! (> scheduled-start block-height) ERR-INVALID-CASE)

    ;; Create case record
    (map-set cases
      { case-id: case-id }
      {
        case-number: case-number,
        case-type: case-type,
        court-room: court-room,
        judge: judge,
        plaintiff: plaintiff,
        defendant: defendant,
        created-at: block-height,
        scheduled-start: scheduled-start,
        estimated-duration: estimated-duration,
        required-jury-size: required-jury-size,
        status: "created",
        priority: priority,
        description: description
      }
    )

    ;; Add creation event to timeline
    (map-set case-timeline
      { case-id: case-id, event-id: u1 }
      {
        event-type: "case-created",
        description: "Case created in system",
        occurred-at: block-height,
        recorded-by: tx-sender
      }
    )

    ;; Increment case ID
    (var-set next-case-id (+ case-id u1))

    (ok case-id)
  )
)

;; Assign jury to case
(define-public (assign-jury
  (case-id uint)
  (selection-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? cases { case-id: case-id })) ERR-CASE-NOT-FOUND)

    ;; Create assignment record
    (map-set case-assignments
      { case-id: case-id }
      {
        selection-id: selection-id,
        assigned-at: block-height,
        jury-confirmed: false,
        trial-started: false,
        verdict-reached: false,
        completed-at: none
      }
    )

    ;; Update case status
    (match (map-get? cases { case-id: case-id })
      case-data
      (begin
        (map-set cases
          { case-id: case-id }
          (merge case-data { status: "jury-assigned" })
        )
        (ok true)
      )
      ERR-CASE-NOT-FOUND
    )
  )
)

;; Update case status
(define-public (update-case-status
  (case-id uint)
  (new-status (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? cases { case-id: case-id })) ERR-CASE-NOT-FOUND)

    (match (map-get? cases { case-id: case-id })
      case-data
      (begin
        (map-set cases
          { case-id: case-id }
          (merge case-data { status: new-status })
        )
        (ok true)
      )
      ERR-CASE-NOT-FOUND
    )
  )
)

;; Mark trial as started
(define-public (start-trial (case-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? case-assignments { case-id: case-id })) ERR-JURY-NOT-ASSIGNED)

    (match (map-get? case-assignments { case-id: case-id })
      assignment-data
      (begin
        (map-set case-assignments
          { case-id: case-id }
          (merge assignment-data { trial-started: true })
        )
        (try! (update-case-status case-id "in-progress"))
        (ok true)
      )
      ERR-JURY-NOT-ASSIGNED
    )
  )
)

;; Record verdict
(define-public (record-verdict (case-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? case-assignments { case-id: case-id })) ERR-JURY-NOT-ASSIGNED)

    (match (map-get? case-assignments { case-id: case-id })
      assignment-data
      (begin
        (map-set case-assignments
          { case-id: case-id }
          (merge assignment-data {
            verdict-reached: true,
            completed-at: (some block-height)
          })
        )
        (try! (update-case-status case-id "completed"))
        (ok true)
      )
      ERR-JURY-NOT-ASSIGNED
    )
  )
)

;; Read-only Functions

;; Get case details
(define-read-only (get-case (case-id uint))
  (map-get? cases { case-id: case-id })
)

;; Get case assignment
(define-read-only (get-case-assignment (case-id uint))
  (map-get? case-assignments { case-id: case-id })
)

;; Get total cases
(define-read-only (get-total-cases)
  (- (var-get next-case-id) u1)
)

;; Check if case exists
(define-read-only (case-exists (case-id uint))
  (is-some (map-get? cases { case-id: case-id }))
)

;; Get case status
(define-read-only (get-case-status (case-id uint))
  (match (map-get? cases { case-id: case-id })
    case-data (some (get status case-data))
    none
  )
)

;; Check if jury is assigned to case
(define-read-only (is-jury-assigned (case-id uint))
  (is-some (map-get? case-assignments { case-id: case-id }))
)
