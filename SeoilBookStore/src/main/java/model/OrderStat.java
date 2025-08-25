package model;

public class OrderStat {
    private String label;   // YYYY / YYYY-MM / YYYY-MM-DD
    private int    count;   // 거래 건수 (DISTINCT transaction_id)
    private Integer sumQty; // 총 수량 (nullable)
    private Long   sumAmount; // 총 금액 (nullable, 금액은 long 권장)

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }

    public int getCount() { return count; }
    public void setCount(int count) { this.count = count; }

    public Integer getSumQty() { return sumQty; }
    public void setSumQty(Integer sumQty) { this.sumQty = sumQty; }

    public Long getSumAmount() { return sumAmount; }
    public void setSumAmount(Long sumAmount) { this.sumAmount = sumAmount; }
}
