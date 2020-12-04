# Copyright 2004-2020 L2J Server
# L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# L2J Server is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

# L2J INTERLUDE

FROM bash

LABEL maintainer="R.C.B. Huls" \
      version="1.0.0"

COPY entrypoint.sh /

RUN chmod 755 /entrypoint.sh

WORKDIR /opt/l2j/

EXPOSE 7777 2106

ENTRYPOINT [ "/entrypoint.sh" ]