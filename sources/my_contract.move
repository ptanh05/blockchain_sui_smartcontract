module certificate::digital_certificate {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::event;

    // Certificate struct - represents a digital certificate NFT
    public struct Certificate has key, store {
        id: UID,
        name: String, // Thêm trường name
        recipient_name: String, 
        course_name: String,
        institution: String,
        issue_date: String,
        completion_date: String,
        description: String,
        issuer: address,
        url: String, // Thêm trường url
    }

    // Event emitted when a certificate is minted
    public struct CertificateMinted has copy, drop {
        certificate_id: address,
        name: String, // Thêm name vào event
        recipient_name: String,
        course_name: String,
        institution: String,
        issuer: address,
        url: String, // Thêm url vào event
    }

    // Capability for institutions to mint certificates
    public struct InstitutionCap has key {
        id: UID,
        institution_name: String,
    }

    // Initialize function - creates institution capability
    fun init(ctx: &mut TxContext) {
        let institution_cap = InstitutionCap {
            id: sui::object::new(ctx),
            institution_name: std::string::utf8(b"Default Institution"),
        };
        transfer::transfer(institution_cap, sui::tx_context::sender(ctx));
    }

    // Mint a new certificate
    public entry fun mint_certificate(
        recipient_name: vector<u8>,
        course_name: vector<u8>,
        institution: vector<u8>,
        issue_date: vector<u8>,
        completion_date: vector<u8>,
        description: vector<u8>,
        name: vector<u8>,
        url: vector<u8>,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let certificate = Certificate {
            id: sui::object::new(ctx),
            name: std::string::utf8(name),
            recipient_name: std::string::utf8(recipient_name),
            course_name: std::string::utf8(course_name),
            institution: std::string::utf8(institution),
            issue_date: std::string::utf8(issue_date),
            completion_date: std::string::utf8(completion_date),
            description: std::string::utf8(description),
            issuer: sui::tx_context::sender(ctx),
            url: std::string::utf8(url),
        };

        let certificate_id = sui::object::uid_to_address(&certificate.id);

        event::emit(CertificateMinted {
            certificate_id,
            name: certificate.name,
            recipient_name: certificate.recipient_name,
            course_name: certificate.course_name,
            institution: certificate.institution,
            issuer: certificate.issuer,
            url: certificate.url,
        });

        transfer::transfer(certificate, recipient);
    }

    // Create institution capability
    public entry fun create_institution_cap(
        institution_name: vector<u8>,
        ctx: &mut TxContext
    ) {
        let institution_cap = InstitutionCap {
            id: sui::object::new(ctx),
            institution_name: std::string::utf8(institution_name),
        };
        transfer::transfer(institution_cap, sui::tx_context::sender(ctx));
    }

    // Getter functions
    public fun get_certificate_details(certificate: &Certificate): (String, String, String, String, String, String, String, String, address) {
        (
            certificate.name,
            certificate.recipient_name,
            certificate.course_name,
            certificate.institution,
            certificate.issue_date,
            certificate.completion_date,
            certificate.description,
            certificate.url,
            certificate.issuer
        )
    }
}