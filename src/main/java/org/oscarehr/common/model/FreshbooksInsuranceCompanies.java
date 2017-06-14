package org.oscarehr.common.model;


import javax.persistence.*;

@Entity
@Table(name="freshbooksInsuranceCompanies")
public class FreshbooksInsuranceCompanies extends AbstractModel<Integer>
{
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;

    @Column(name = "freshbooks_id", nullable = false)
    private String freshbooksId;

    @Column(name = "company_id", nullable = false)
    private String companyId;

    @Column(name = "provider_no", nullable = false)
    private String providerNo;

    public String getFreshbooksId() {
        return freshbooksId;
    }

    public void setFreshbooksId(String freshbooksId) {
        this.freshbooksId = freshbooksId;
    }

    public String getCompanyId() {
        return companyId;
    }

    public void setCompanyId(String companyId) {
        this.companyId = companyId;
    }

    public String getProviderNo() {
        return providerNo;
    }

    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    @Override
    public Integer getId() {return id;}

    public void setId(Integer id) {this.id = id;}


}
