;; title: WIT Token
;; version: 1.0.0
;; summary: Mock SIP-010 fungible token used as WitStac reward (replaces real STX for dev/testnet)
;; description: WIT is the reward token for the WitStac trivia game. Players earn WIT for correct answers.
;;              This mock implementation allows full game testing without spending real STX.

;; ============================================================
;; SIP-010 Trait Implementation
;; ============================================================

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; ============================================================
;; Token Definition
;; ============================================================

(define-fungible-token wit-token)

;; ============================================================
;; Constants
;; ============================================================

(define-constant contract-owner tx-sender)
(define-constant token-name "WitStac Token")
(define-constant token-symbol "WIT")
(define-constant token-decimals u6)
(define-constant token-uri (some u"https://witstac.app/token/wit"))

;; ---- Error codes ----
(define-constant err-not-owner          (err u300))
(define-constant err-not-authorized     (err u301))
(define-constant err-insufficient-funds (err u302))

;; ============================================================
;; SIP-010 Required Functions
;; ============================================================

(define-public (transfer
    (amount uint)
    (sender principal)
    (recipient principal)
    (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (try! (ft-transfer? wit-token amount sender recipient))
    (match memo
      m (print m)
      true)
    (ok true)))

(define-read-only (get-name)
  (ok token-name))

(define-read-only (get-symbol)
  (ok token-symbol))

(define-read-only (get-decimals)
  (ok token-decimals))

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance wit-token account)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply wit-token)))

(define-read-only (get-token-uri)
  (ok token-uri))

;; ============================================================
;; Mint / Burn (owner-only for minting; burn is self-serve)
;; ============================================================

;; Mint WIT tokens — only callable by the contract owner OR the witstac game contract
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (or (is-eq tx-sender contract-owner)
                  (is-eq contract-caller .witstac))
              err-not-owner)
    (ft-mint? wit-token amount recipient)))

;; Burn WIT tokens (any holder can burn their own tokens)
(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    (ft-burn? wit-token amount owner)))

;; ============================================================
;; Admin: Airdrop for initial seeding / testing
;; ============================================================

(define-public (airdrop (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner)
    (ft-mint? wit-token amount recipient)))
