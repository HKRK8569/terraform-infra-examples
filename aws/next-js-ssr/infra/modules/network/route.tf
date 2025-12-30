
# パブリックサブネット用のルートテーブルの定義
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
    Tier = "public"
  })
}

# Public -> Internet
# publicからinternetの全てをinternetGatewayに流す
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# パブリックサブネットとrouteTableの紐付け
resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# プライベートサブネット用のルートテーブルの定義
resource "aws_route_table" "private" {
  count  = length(var.azs)
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt-${var.azs[count.index]}"
    Tier = "private"
  })
}

# Private -> Internet
# プライベートネットワークからインターネットの全てはnatGatewayを経由して外に出る
resource "aws_route" "private_nat" {
  count                  = length(var.azs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

# パブリックサブネットとrouteTableの紐付け
resource "aws_route_table_association" "private" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
