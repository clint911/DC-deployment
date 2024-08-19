
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

struct ContractStats {
    uint64 causes;
    uint64 events;
    uint64 campaigns;
    uint64 donations;
    uint64 tokens;
    uint64 partners;
    uint256 total_usd;
}

struct Donation {
    uint256 campaignId;
    address donor;
    uint256 amount;
    string date;
}

struct Campaign {
    uint256 id;
    string title;
    string cause;
    string image;
    string description;
    string start_date;
    string end_date;
    address donation_token;
    uint256 total;
    uint256 donations_count;
    uint256 target;
    uint256 voters_count;
    uint256 partners_count;
    address[] voters_addresses;
    mapping(address => bool) voters;
    string[] partner_ids;
    mapping(string => uint256) partner_votes;
}

struct ReturnCampaign {
    uint256 id;
    string title;
    string cause;
    string description;
    string image;
    string start_date;
    address donation_token;
    uint256 total;
    uint256 donations_count;
    uint256 target;
}

struct Partner {
    string id;
    string name;
    string logo;
    string expertise_fields;
    address wallet;
}

contract Donations {
    address[] private guardians;
    bool public running;
    string[] private causes;
    mapping(uint256 => Campaign) private campaigns;
    mapping(address => uint256[]) private my_campaigns;
    mapping(uint256 => Donation[]) private campaignDonations;

    string[] private tokens;
    mapping(string => Partner) private partners;
    mapping(address => string[]) private account_partners;

    uint public total_usd;

    uint64 public causes_count;
    uint64 public events_count;
    uint64 public campaigns_count;
    uint64 public donations_count;
    uint64 public tokens_count;
    uint64 public partners_count;

    uint256 private donationsPerPage = 10;
    uint256 private campaignsPerPage = 20;

    constructor() {
        guardians.push(msg.sender);
        running = true;
    }

    function addToken(string memory token) public {
        tokens.push(token);
        tokens_count++;
    }

    function getTokens() public view returns (string[] memory) {
        return tokens;
    }

    function addCause(string memory cause) public {
        causes.push(cause);
        causes_count++;
    }

    function getCauses() public view returns (string[] memory) {
        return causes;
    }

    function getDonationsStats() public view returns (ContractStats memory) {
        ContractStats memory stats;
        stats.causes = causes_count;
        stats.events = events_count;
        stats.campaigns = campaigns_count;
        stats.donations = donations_count;
        stats.tokens = tokens_count;
        stats.partners = partners_count;
        stats.total_usd = total_usd;
        return stats;
    }

    function registerPartner(
        string memory id,
        string memory name,
        string memory logo,
        string memory expertise_fields,
        address wallet
    ) public {
        Partner memory partner = Partner(
            id,
            name,
            logo,
            expertise_fields,
            wallet
        );
        partners[id] = partner;
        account_partners[msg.sender].push(id);
        partners_count += 1;
    }

    function getAccountPartners() public view returns (string[] memory) {
        return account_partners[msg.sender];
    }

    function getPartner(string memory id) public view returns (Partner memory) {
        return partners[id];
    }

    function createCampaign(
        string memory title,
        address donation_token,
        uint256 target,
        string memory cause,
        string memory description,
        string memory image,
        string memory start_date,
        string memory end_date
    ) public {
        campaigns_count += 1;
        Campaign storage newCampaign = campaigns[campaigns_count];
        newCampaign.id = campaigns_count;
        newCampaign.title = title;
        newCampaign.donation_token = donation_token;
        newCampaign.cause = cause;
        newCampaign.image = image;
        newCampaign.start_date = start_date;
        newCampaign.end_date = end_date;
        newCampaign.description = description;
        newCampaign.total = 0;
        newCampaign.donations_count = 0;
        newCampaign.voters_count = 0;
        newCampaign.partners_count = 0;
        newCampaign.target = target;

        my_campaigns[msg.sender].push(campaigns_count);

        // Initialize voters
        // for (uint256 i = 0; i < initialVoters.length; i++) {
        //     newCampaign.voters[initialVoters[i]] = true;
        // }

        // Initialize partners
        // for (uint256 i = 0; i < initialPartners.length; i++) {
        //     newCampaign.partners[initialPartners[i]] = 0;
        // }
    }

    function getCampaign(uint id) public view returns (ReturnCampaign memory) {
        Campaign storage camp = campaigns[id];
        ReturnCampaign memory return_camp = ReturnCampaign(
            camp.id,
            camp.title,
            camp.cause,
            camp.description,
            camp.image,
            camp.start_date,
            camp.donation_token,
            camp.total,
            camp.donations_count,
            camp.target
        );
        return return_camp;
    }

    function donate(
        uint256 campaignId,
        uint256 amount,
        string memory date
    ) external payable {
        // require(
        //     campaigns[campaignId].donation_token == msg.sender,
        //     "Invalid donation token"
        // );

        Donation memory newDonation = Donation(
            campaignId,
            msg.sender,
            amount,
            date
        );

        campaignDonations[campaignId].push(newDonation);
        campaigns[campaignId].total += amount;
        campaigns[campaignId].donations_count += 1;

        campaigns[campaignId].voters_addresses.push(msg.sender);
        campaigns[campaignId].voters[msg.sender] = true;
    }

    function registerCampaignPartner(
        uint256 campaignId,
        string memory partner_id
    ) public {
        Campaign storage campaign = campaigns[campaignId];
        campaign.partner_ids.push(partner_id);
        campaign.partner_votes[partner_id] = 0;
    }

    function getCampaignDonations(
        uint256 campaignId,
        uint256 page
    ) public view returns (Donation[] memory) {
        uint256 start = donationsPerPage * (page - 1);
        uint256 end = start + donationsPerPage;
        uint256 totalDonations = campaignDonations[campaignId].length;

        if (start >= totalDonations) {
            return new Donation[](0);
        }

        if (end > totalDonations) {
            end = totalDonations;
        }

        Donation[] memory result = new Donation[](end - start);

        for (uint256 i = start; i < end; i++) {
            result[i - start] = campaignDonations[campaignId][i];
        }

        return result;
    }

    function getCampaigns(
        uint256 page
    ) public view returns (ReturnCampaign[] memory) {
        uint256 start = campaignsPerPage * (page - 1);
        uint256 end = start + campaignsPerPage;
        uint256 totalCampaigns = campaigns_count;

        if (start >= totalCampaigns) {
            return new ReturnCampaign[](0);
        }

        if (end > totalCampaigns) {
            end = totalCampaigns;
        }

        ReturnCampaign[] memory result = new ReturnCampaign[](end - start);

        for (uint256 i = start; i < end; i++) {
            // result[i - start] = campaignDonations[campaignId][i];
            Campaign storage camp = campaigns[i];
            ReturnCampaign memory return_camp = ReturnCampaign(
                camp.id,
                camp.title,
                camp.cause,
                camp.description,
                camp.image,
                camp.start_date,
                camp.donation_token,
                camp.total,
                camp.donations_count,
                camp.target
            );
            result[i - start] = return_camp;
        }

        return result;
    }

    function getCampaignVoters(
        uint256 campaignId
    ) public view returns (address[] memory) {
        require(campaignId <= campaigns_count, "Invalid campaign ID");
        Campaign storage campaign = campaigns[campaignId];
        return campaign.voters_addresses;
    }

    function getCampaignVoter(uint256 campaignId) public view returns (bool) {
        require(campaignId <= campaigns_count, "Invalid campaign ID");
        Campaign storage campaign = campaigns[campaignId];
        return campaign.voters[msg.sender];
    }

    function vote(uint256 campaignId, string memory partner_id) public {
        Campaign storage campaign = campaigns[campaignId];
        bool voter = campaign.voters[msg.sender];
        if (voter) {
            campaign.partner_votes[partner_id] += 1;
            delete campaign.voters[msg.sender];
        }
    }

    function getCampaignPartners(
        uint256 campaignId
    ) public view returns (string[] memory, uint256[] memory) {
        require(campaignId <= campaigns_count, "Invalid campaign ID");
        Campaign storage campaign = campaigns[campaignId];
        uint256 partnersCount = campaign.partner_ids.length;
        uint256[] memory partnerVotes = new uint256[](partnersCount);
        uint256 index = 0;
        for (uint256 i = 0; i < partnersCount; i++) {
            string memory partnerName = campaign.partner_ids[i];
            partnerVotes[index] = campaign.partner_votes[partnerName];
            index++;
        }
        return (campaign.partner_ids, partnerVotes);
    }
}
